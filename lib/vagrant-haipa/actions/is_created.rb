module VagrantPlugins
  module Haipa
    module Actions
      class IsCreated
        def initialize(app, env)
          @app = app
          @machine = env[:machine]
          @logger = Log4r::Logger.new('vagrant::haipa::is_created')
        end

        def call(env)
          env[:result] = env[:machine].state.id != :not_created
          @app.call(env)
        end
      end
    end
  end
end
