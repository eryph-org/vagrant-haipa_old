module VagrantPlugins
  module Haipa
    class Config < Vagrant.plugin('2', :config)
      attr_accessor :token
      attr_accessor :image
      attr_accessor :region
      attr_accessor :flavor

      attr_accessor :name

      attr_accessor :vm_config
      attr_accessor :provision
      

      def initialize
        @token              = UNSET_VALUE
        @image              = UNSET_VALUE
        @region             = UNSET_VALUE
        @flavor             = UNSET_VALUE

        @name               = UNSET_VALUE
        @vm_config          = UNSET_VALUE
        @provision          = UNSET_VALUE
      end

      def finalize!
        @token              = ENV['DO_TOKEN'] if @token == UNSET_VALUE
        @image              = 'ubuntu-14-04-x64' if @image == UNSET_VALUE
        @region             = 'nyc2' if @region == UNSET_VALUE
        @flavor             = 'default' if @size == UNSET_VALUE
        @name               = nil if @name == UNSET_VALUE
        @vm_config          = [] if @vm_config == UNSET_VALUE
        @provision          = [] if @provision == UNSET_VALUE
      end

      def validate(machine)
        errors = []
        #errors << I18n.t('vagrant_haipa.config.token') if !@token

        key = machine.config.ssh.private_key_path
        key = key[0] if key.is_a?(Array)
#        if !key
#          errors << I18n.t('vagrant_haipa.config.private_key')
#        elsif !File.file?(File.expand_path("#{key}.pub", machine.env.root_path))
#          errors << I18n.t('vagrant_haipa.config.public_key', {
#            :key => "#{key}.pub"
#          })
       # end

        { 'Haipa Provider' => errors }
      end
    end
  end
end
