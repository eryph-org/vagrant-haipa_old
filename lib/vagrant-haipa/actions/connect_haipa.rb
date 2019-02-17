require 'vagrant-haipa'

module VagrantPlugins
  module Haipa
    module Actions
      class ConnectHaipa
        include Helpers::Client

        def initialize(app, env)
          @app = app
          @machine = env[:machine]
          @client = client
          @logger = Log4r::Logger.new('vagrant::haipa::ConnectHaipa')
        end

        def call(env)
          @app.call(env)
        end
      end
    end
  end
end


