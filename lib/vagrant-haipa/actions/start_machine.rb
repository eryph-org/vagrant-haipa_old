require 'vagrant-haipa'

module VagrantPlugins
  module Haipa
    module Actions
      class StartMachine
        include Helpers::Client

        def initialize(app, env)
          @app = app
          @machine = env[:machine]
          @client = client
          @logger = Log4r::Logger.new('vagrant::haipa::power_on')
        end

        def call(env)
          # submit power on droplet request
          result = @client.post("/odata/Machines(#{@machine.id})/Start")

          # wait for request to complete
          env[:ui].info I18n.t('vagrant_haipa.info.powering_on') 
          @client.wait_for_event(env, result['Id'])

          # refresh droplet state with provider
          Provider.droplet(@machine, :refresh => true)

          @app.call(env)
        end
      end
    end
  end
end


