require 'vagrant-haipa/actions/check_state'
require 'vagrant-haipa/actions/create'
require 'vagrant-haipa/actions/destroy'
require 'vagrant-haipa/actions/shut_down'
require 'vagrant-haipa/actions/power_off'
require 'vagrant-haipa/actions/power_on'
require 'vagrant-haipa/actions/rebuild'
require 'vagrant-haipa/actions/reload'
require 'vagrant-haipa/actions/setup_user'
require 'vagrant-haipa/actions/setup_sudo'
require 'vagrant-haipa/actions/setup_key'
require 'vagrant-haipa/actions/modify_provision_path'

module VagrantPlugins
  module Haipa
    module Actions
      include Vagrant::Action::Builtin

      def self.destroy
        return Vagrant::Action::Builder.new.tap do |builder|
          builder.use ConfigValidate
          builder.use Call, CheckState do |env, b|
            case env[:machine_state]
            when :not_created
              env[:ui].info I18n.t('vagrant_haipa.info.not_created')
            else
              b.use Call, DestroyConfirm do |env2, b2|
                if env2[:result]
                  b2.use Destroy
                  b2.use ProvisionerCleanup if defined?(ProvisionerCleanup)
                end
              end
            end
          end
        end
      end

      def self.ssh
        return Vagrant::Action::Builder.new.tap do |builder|
          builder.use ConfigValidate
          builder.use Call, CheckState do |env, b|
            case env[:machine_state]
            when :Running
              b.use SSHExec
            when :Stopped
              env[:ui].info I18n.t('vagrant_haipa.info.off')
            when :not_created
              env[:ui].info I18n.t('vagrant_haipa.info.not_created')
            end
          end
        end
      end

      def self.ssh_run
        return Vagrant::Action::Builder.new.tap do |builder|
          builder.use ConfigValidate
          builder.use Call, CheckState do |env, b|
            case env[:machine_state]
            when :Running
              b.use SSHRun
            when :Stopped
              env[:ui].info I18n.t('vagrant_haipa.info.off')
            when :not_created
              env[:ui].info I18n.t('vagrant_haipa.info.not_created')
            end
          end
        end
      end

      def self.provision
        return Vagrant::Action::Builder.new.tap do |builder|
          builder.use ConfigValidate
          builder.use Call, CheckState do |env, b|
            case env[:machine_state]
            when :Running
              b.use Provision
              b.use ModifyProvisionPath
              b.use SyncedFolders
            when :Stopped
              env[:ui].info I18n.t('vagrant_haipa.info.off')
            when :not_created
              env[:ui].info I18n.t('vagrant_haipa.info.not_created')
            end
          end
        end
      end

      def self.up
        return Vagrant::Action::Builder.new.tap do |builder|
          builder.use ConfigValidate
          builder.use Call, CheckState do |env, b|
            case env[:machine_state]
            when :Running
              env[:ui].info I18n.t('vagrant_haipa.info.already_active')
            when :Stopped
              b.use PowerOn
              b.use provision
            when :not_created
              #b.use SetupKey
              b.use Create
              b.use PowerOn
              #b.use SetupSudo
              #b.use SetupUser
              b.use provision
            end
          end
        end
      end

      def self.halt
        return Vagrant::Action::Builder.new.tap do |builder|
          builder.use ConfigValidate
          builder.use Call, CheckState do |env, b|
            case env[:machine_state]
            when :Running
              if env[:force_halt]
                b.use PowerOff
              else
                b.use ShutDown
              end
            when :off
              env[:ui].info I18n.t('vagrant_haipa.info.already_off')
            when :not_created
              env[:ui].info I18n.t('vagrant_haipa.info.not_created')
            end
          end
        end
      end

      def self.reload
        return Vagrant::Action::Builder.new.tap do |builder|
          builder.use ConfigValidate
          builder.use Call, CheckState do |env, b|
            case env[:machine_state]
            when :Running
              b.use Reload
              b.use provision
            when :Stopped
              env[:ui].info I18n.t('vagrant_haipa.info.off')
            when :not_created
              env[:ui].info I18n.t('vagrant_haipa.info.not_created')
            end
          end
        end
      end

      def self.rebuild
        return Vagrant::Action::Builder.new.tap do |builder|
          builder.use ConfigValidate
          builder.use Call, CheckState do |env, b|
            case env[:machine_state]
            when :Running, :Stopped
              b.use Rebuild
              #b.use SetupSudo
              #b.use SetupUser
              b.use provision
            when :not_created
              env[:ui].info I18n.t('vagrant_haipa.info.not_created')
            end
          end
        end
      end
    end
  end
end
