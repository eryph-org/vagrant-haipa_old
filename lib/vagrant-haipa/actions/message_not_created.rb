module VagrantPlugins
  module Haipa
    module Actions
      class MessageNotCreated
        def initialize(app, env)
          @app = app
        end

        def call(env)
          env[:ui].info I18n.t('vagrant_haipa.info.not_created')
          @app.call(env)
        end
      end
    end
  end
end
