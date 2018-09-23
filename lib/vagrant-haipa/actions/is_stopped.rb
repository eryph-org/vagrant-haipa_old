module VagrantPlugins
  module Haipa
    module Actions
      class IsStopped
        def initialize(app, env)
          @app = app
          @machine = env[:machine]
          @logger = Log4r::Logger.new('vagrant::haipa::is_stopped')
        end

        def call(env)
          env[:result] = env[:machine].state.id == :Stopped
          @app.call(env)
        end
      end
    end
  end
end
