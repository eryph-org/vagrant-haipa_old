require 'vagrant-haipa'

module VagrantPlugins
  module Haipa
    module Actions
      class Reload
        include Helpers::Client

        def initialize(app, env)
          @app = app
          @machine = env[:machine]
          @client = client
          @logger = Log4r::Logger.new('vagrant::haipa::reload')
        end

        def call(env)
          # submit reboot droplet request
          result = @client.post("/v2/droplets/#{@machine.id}/actions", {
            :type => 'reboot'
          })

          # wait for request to complete
          env[:ui].info I18n.t('vagrant_haipa.info.reloading')
          @client.wait_for_event(env, result['action']['id'])

          @app.call(env)
        end
      end
    end
  end
end


