require 'vagrant-haipa'

module VagrantPlugins
  module Haipa
    module Actions
      class SetName
        include Helpers::Client

        def initialize(app, env)
          @app = app
          @machine = env[:machine]
          @client = client
          @logger = Log4r::Logger.new('vagrant::haipa::set_name')
        end

        def call(env)
          name = @machine.provider_config.name

          # If we already set the name before, then don't do anything
          sentinel = @machine.data_dir.join("action_set_name")
          if !name && sentinel.file?
            @logger.info("Default name was already set before, not doing it again.")
            return @app.call(env)
          end

          # If no name was manually set, then use a default
          if !name
            prefix = "#{env[:root_path].basename.to_s}_#{@machine.name}"
            prefix.gsub!(/[^-a-z0-9_]/i, "")

            # milliseconds + random number suffix to allow for simultaneous
            # `vagrant up` of the same box in different dirs
            name = prefix + "_#{(Time.now.to_f * 1000.0).to_i}_#{rand(100000)}"
          end

          # Verify the name is not taken
          haipa_machine = Provider.haipa_machines(@machine).find { |d| d['name'].to_s == name }
          raise Vagrant::Errors::VMNameExists, name: name if haipa_machine
          
          env[:generated_name] = name
          # Create the sentinel
          sentinel.open("w") do |f|
            f.write(Time.now.to_i.to_s)
          end
          
          @app.call(env)
        end
      end
    end
  end
end


