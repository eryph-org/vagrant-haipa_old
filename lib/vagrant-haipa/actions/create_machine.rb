require 'vagrant-haipa/helpers/client'

module VagrantPlugins
  module Haipa
    module Actions
      class CreateMachine
        include Helpers::Client
        include Vagrant::Util::Retryable

        def initialize(app, env)
          @app = app
          @machine = env[:machine]
          @client = client
          @logger = Log4r::Logger.new('vagrant::haipa::create_machine')
        end

        def call(env)
          ssh_key_id = [env[:ssh_key_id]]

          # submit new droplet request
          result = @client.post('/odata/Machines', {

                  'Name' => 'basic2',                           
                  'VM' => {
                    'Path' => 't:\\openstack\\vms',
                    'Memory' => {
                      'Startup' => 2048
                    },
                    'Disks' => [
                      {
                        "Template" => "t:\\openstack\\ubuntu-xenial.vhdx",
                        "Size" => 20
                      },
                    ],  
                    'NetworkAdapters' => [
                      {
                        "Name" => "eth0",
                        "SwitchName" => "Standardswitch",
                      },                                                          
                    ],
                  },
                  "Provisioning" => {
                    'Hostname' => 'basic',
                    "UserData" => {
                      "password" => "ubuntu",
                      "chpasswd" => {
                        "expire"=> "False"
                    }
                  }
                }
              
        })

          # wait for request to complete
          env[:ui].info I18n.t('vagrant_haipa.info.creating')
          @client.wait_for_event(env, result['Id'])

          # assign the machine id for reference in other commands
          operation_result = @client.request("odata/Operations(#{result['Id']})")
          @machine.id = operation_result['MachineGuid'].to_s

          @app.call(env)
        end

        # Both the recover and terminate are stolen almost verbatim from
        # the Vagrant AWS provider up action
        def recover(env)
          return if env['vagrant.error'].is_a?(Vagrant::Errors::VagrantError)
          terminate(env) if @machine.state.id != :not_created
        end

        def terminate(env)
          destroy_env = env.dup
          destroy_env.delete(:interrupted)
          destroy_env[:config_validate] = false
          destroy_env[:force_confirm_destroy] = true
          env[:action_runner].run(Actions.action_destroy, destroy_env)
        end
      end
    end
  end
end
