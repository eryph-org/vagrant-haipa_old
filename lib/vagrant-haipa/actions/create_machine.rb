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

          # submit new machine request
          result = @client.post('/odata/v1/Machines', {

                  'name' => env[:generated_name],                           
                  'vm' => @machine.provider_config.vm_config,
                  "provisioning" => @machine.provider_config.provision            
        })

          # wait for request to complete
          env[:ui].info I18n.t('vagrant_haipa.info.creating')
          operation_id = result['id']
          @client.wait_for_event(env, operation_id)

          # assign the machine id for reference in other commands
          operation_result = @client.request("odata/Operations(#{operation_id})")
          @machine.id = operation_result['machineGuid'].to_s

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
