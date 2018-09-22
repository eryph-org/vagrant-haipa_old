require 'vagrant-haipa/helpers/client'

module VagrantPlugins
  module Haipa
    module Actions
      class Destroy
        include Helpers::Client

        def initialize(app, env)
          @app = app
          @machine = env[:machine]
          @client = client
          @logger = Log4r::Logger.new('vagrant::haipa::destroy')
        end

        def call(env)
          # submit destroy droplet request
          @client.delete("/odata/machineSet(#{@machine.id})")

          env[:ui].info I18n.t('vagrant_haipa.info.destroying')

          # set the machine id to nil to cleanup local vagrant state
          @machine.id = nil

          @app.call(env)
        end
      end
    end
  end
end
