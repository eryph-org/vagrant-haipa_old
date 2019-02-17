require 'vagrant-haipa/helpers/client'

module VagrantPlugins
  module Haipa
    module Actions
      class DeleteMachine
        include Helpers::Client

        def initialize(app, env)
          @app = app
          @machine = env[:machine]
          @client = client
          @logger = Log4r::Logger.new('vagrant::haipa::DeleteMachine')
        end

        def call(env)
          # submit delete machine request
          result = @client.delete("/odata/Machines(#{@machine.id})")

          env[:ui].info I18n.t('vagrant_haipa.info.destroying')
          @client.wait_for_event(env, result['Id'])

          # set the machine id to nil to cleanup local vagrant state
          @machine.id = nil

          @app.call(env)
        end
      end
    end
  end
end
