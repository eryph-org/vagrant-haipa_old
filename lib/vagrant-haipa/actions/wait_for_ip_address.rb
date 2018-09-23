module VagrantPlugins
  module Haipa
    module Actions
      class WaitForIpAddress
        include Vagrant::Util::Retryable

        def initialize(app, env)
          @app = app
          @machine = env[:machine]
          @logger = Log4r::Logger.new('vagrant::haipa::wait_for_ip_address')
        end

        def call(env)
          # refresh droplet state with provider and output ip address
          retryable(:tries => 20, :sleep => 10) do
            next if env[:interrupted]

            machine = Provider.droplet(@machine, :refresh => true)
            address = machine['IpV4Addresses'].first
            raise 'not ready' unless address

            env[:ui].info I18n.t('vagrant_haipa.info.machine_ip', :ip => address)
          end

          @app.call(env)
        end
      end
    end
  end
end
