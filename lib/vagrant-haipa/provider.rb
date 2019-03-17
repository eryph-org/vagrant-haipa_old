require 'vagrant-haipa/actions'
require 'vagrant-haipa/helpers/client'

module VagrantPlugins
  module Haipa
    class Provider < Vagrant.plugin('2', :provider)

      def self.haipa_machines(machine)
        client = Helpers::ApiClient.new(machine)

        unless @haipa_machines
          result = client.request('/odata/v1/Machines', {'$expand' => 'Networks' })
          @haipa_machines = result['value']
        end
        return @haipa_machines
      end

      # This class method caches status for all machines within
      # the Haipa account. A specific machine's status
      # may be refreshed by passing :refresh => true as an option.
      def self.haipa_machine(machine, opts = {})
        client = Helpers::ApiClient.new(machine)

        # load status of machines if it has not been done before
        haipa_machines(machine)

        if opts[:refresh] && machine.id
          # refresh the machine status for the given machine
          @haipa_machines.delete_if { |d| d['id'].to_s == machine.id }
          result = client.request("/odata/v1/Machines(#{machine.id})", {'$expand' => 'Networks' })
          @haipa_machines << haipa_machine = result
        else
          # lookup machine status for the given machine
          haipa_machine = @haipa_machines.find { |d| d['id'].to_s == machine.id }
        end

        # if lookup by id failed, check for a machine with a matching name
        # and set the id to ensure vagrant stores locally
        # TODO allow the user to configure this behavior
        unless haipa_machine
          name = machine.config.vm.hostname || machine.name
          haipa_machine = @haipa_machines.find { |d| d['name'] == name.to_s }
          machine.id = haipa_machine['id'].to_s if haipa_machine
        end

        haipa_machine || { 'status' => 'not_created' }
      end

      def initialize(machine)
        @machine = machine
      end

      def action(name)
        # Attempt to get the action method from the Action class if it
        # exists, otherwise return nil to show that we don't support the
        # given action.
        action_method = "action_#{name}"
        return Actions.send(action_method) if Actions.respond_to?(action_method)
        nil
      end

      # This method is called if the underying machine ID changes. Providers
      # can use this method to load in new data for the actual backing
      # machine or to realize that the machine is now gone (the ID can
      # become `nil`). No parameters are given, since the underlying machine
      # is simply the machine instance given to this object. And no
      # return value is necessary.
      def machine_id_changed
      end

      # This should return a hash of information that explains how to
      # SSH into the machine. If the machine is not at a point where
      # SSH is even possible, then `nil` should be returned.
      #
      # The general structure of this returned hash should be the
      # following:
      #
      #     {
      #       :host => "1.2.3.4",
      #       :port => "22",
      #       :username => "mitchellh",
      #       :private_key_path => "/path/to/my/key"
      #     }
      #
      # **Note:** Vagrant only supports private key based authenticatonion,
      # mainly for the reason that there is no easy way to exec into an
      # `ssh` prompt with a password, whereas we can pass a private key
      # via commandline.
      def ssh_info
        machine = Provider.haipa_machine(@machine)

        return nil if machine['status'].to_sym != :Running


        # Run a custom action called "ssh_ip" which does what it says and puts
        # the IP found into the `:machine_ip` key in the environment.
        env = @machine.action("ssh_ip")

        # If we were not able to identify the machine IP, we return nil
        # here and we let Vagrant core deal with it ;)
        return nil unless env[:machine_ip]

       return {
           :host => env[:machine_ip],
        }
      end

      # This should return the state of the machine within this provider.
      # The state must be an instance of {MachineState}. Please read the
      # documentation of that class for more information.
      def state
        state = :error
        haipa_machine = Provider.haipa_machine(@machine)
        
        state = haipa_machine['status'].downcase.to_sym if haipa_machine
        long = short = state.to_s
        Vagrant::MachineState.new(state, short, long)
      end
    end
  end
end
