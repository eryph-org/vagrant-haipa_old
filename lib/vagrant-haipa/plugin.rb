module VagrantPlugins
  module Haipa
    class Plugin < Vagrant.plugin('2')
      name 'Haipa'
      description <<-DESC
        This plugin installs a provider that allows Vagrant to manage
        machines using Haipa's API.
      DESC

      config(:haipa, :provider) do
        require_relative 'config'
        Config
      end

      provider(:haipa, parallel: true, defaultable: false) do
        require_relative 'provider'
        Provider
      end

      command(:rebuild) do
        require_relative 'commands/rebuild'
        Commands::Rebuild
      end

      command("haipa-list", primary: false) do
        require_relative 'commands/list'
        Commands::List
      end
    end
  end
end
