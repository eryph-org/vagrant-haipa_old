require 'vagrant-haipa/actions/check_state'
require 'vagrant-haipa/actions/create'
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

      # This action is called to terminate the remote machine.
      def self.action_destroy
        Vagrant::Action::Builder.new.tap do |b|
          b.use Call, DestroyConfirm do |env, b2|
            if env[:result]
              b2.use ConfigValidate
              b2.use Call, IsCreated do |env2, b3|
                unless env2[:result]
                  b3.use MessageNotCreated
                  next
                end

                b3.use ProvisionerCleanup, :before if defined?(ProvisionerCleanup)
                b3.use DeleteMachine
              end
            else
              b2.use MessageWillNotDestroy
            end
          end
        end
      end

      def self.action_ssh
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

      def self.action_ssh_run
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

      def self.action_provision
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

      def self.action_prepare_boot
        Vagrant::Action::Builder.new.tap do |b|
          b.use Provision
          b.use SyncedFolders
        end
      end

      def self.action_up
        Vagrant::Action::Builder.new.tap do |b|
          #b.use HandleBox
          b.use ConfigValidate
          #b.use BoxCheckOutdated
          b.use Call, IsCreated do |env1, b1|
            if env1[:result]
              b1.use Call, IsStopped do |env2, b2|
                if env2[:result]
                  b2.use action_prepare_boot
                  b2.use PowerOn
                else
                  env[:ui].info I18n.t('vagrant_haipa.info.already_active')
                end
              end
            else
              b1.use Create
              b1.use action_prepare_boot
              b1.use PowerOn
            end
          end
        end
      end

      def self.action_halt
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

      def self.action_reload
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

      def self.action_rebuild
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

  # The autoload farm
  action_root = Pathname.new(File.expand_path('../actions', __FILE__))
  autoload :IsCreated, action_root.join('is_created')
  autoload :IsStopped, action_root.join('is_stopped')
  autoload :MessageNotCreated, action_root.join('message_not_created')
  autoload :MessageWillNotDestroy, action_root.join('message_will_not_destroy')
  autoload :DeleteMachine, action_root.join('delete_machine')
end
