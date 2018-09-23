module VagrantPlugins
  module Haipa
    module Actions
      include Vagrant::Action::Builtin

      # This action is called to halt the remote machine.
      def self.action_halt
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, IsCreated do |env, b2|
            unless env[:result]
              b2.use MessageNotCreated
              next
            end

            b2.use ConnectHaipa
            b2.use StopMachine
          end
        end
      end

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

                b3.use ConnectHaipa
                b3.use ProvisionerCleanup, :before if defined?(ProvisionerCleanup)
                b3.use DeleteMachine
              end
            else
              b2.use MessageWillNotDestroy
            end
          end
        end
      end

      # This action is called when `vagrant provision` is called.
      def self.action_provision
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, IsCreated do |env, b2|
            unless env[:result]
              b2.use MessageNotCreated
              next
            end

            b2.use Provision
            b2.use SyncedFolderCleanup
            b2.use SyncedFolders
          end
        end
      end

      # This action is called to read the SSH info of the machine. The
      # resulting state is expected to be put into the `:machine_ssh_info`
      # key.
      def self.action_read_ssh_info
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use ConnectHaipa
          b.use ReadSSHInfo
        end
      end

      # This action is called to read the state of the machine. The
      # resulting state is expected to be put into the `:machine_state_id`
      # key.
      def self.action_read_state
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use ConnectHaipa
          b.use ReadState
        end
      end

      # This action is called to SSH into the machine.
      def self.action_ssh
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, IsCreated do |env, b2|
            unless env[:result]
              b2.use MessageNotCreated
              next
            end

            b2.use SSHExec
          end
        end
      end

      def self.action_ssh_run
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, IsCreated do |env, b2|
            unless env[:result]
              b2.use MessageNotCreated
              next
            end

            b2.use SSHRun
          end
        end
      end

      def self.action_start
        Vagrant::Action::Builder.new.tap do |b|
          b.use Call, IsState, :running do |env1, b1|
            if env1[:result]
              b1.use action_provision
              next
            end

            b1.use Call, IsState, :paused do |env2, b2|
              if env2[:result]
                b2.use action_resume
                next
              end

              b2.use Provision
              b2.use StartMachine
              b2.use WaitForIpAddress
              b2.use WaitForCommunicator, [:running]
              b2.use SyncedFolderCleanup
              b2.use SyncedFolders
              b2.use SetHostname
            end
          end
        end
      end

      # This action is called to bring the box up from nothing.
      def self.action_up
        Vagrant::Action::Builder.new.tap do |b|
          # b.use HandleBox
          b.use ConfigValidate
          # b.use BoxCheckOutdated
          b.use ConnectHaipa
          b.use Call, IsCreated do |env1, b1|
            if env1[:result]
              b1.use Call, IsStopped do |env2, b2|
                if env2[:result]
                  b2.use action_start
                else
                  b2.use MessageAlreadyCreated
                end
              end
            else
              b1.use CreateMachine
              b1.use action_start
            end
          end
        end
      end

      def self.action_reload
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use ConnectHaipa
          b.use Call, IsCreated do |env, b2|
            unless env[:result]
              b2.use MessageNotCreated
              next
            end

            b2.use action_halt
            b2.use Call, WaitForState, :stopped, 120 do |env2, b3|
              if env2[:result]
                b3.use action_up
              else
                # TODO we couldn't reach :stopped, what now?
              end
            end
          end
        end
      end

      # The autoload farm
      action_root = Pathname.new(File.expand_path('../actions', __FILE__))
      autoload :ConnectHaipa, action_root.join('connect_haipa')
      autoload :IsCreated, action_root.join('is_created')
      autoload :IsStopped, action_root.join('is_stopped')
      autoload :MessageAlreadyCreated, action_root.join('message_already_created')      
      autoload :MessageNotCreated, action_root.join('message_not_created')
      autoload :MessageWillNotDestroy, action_root.join('message_will_not_destroy')
      autoload :CreateMachine, action_root.join('create_machine')
      autoload :DeleteMachine, action_root.join('delete_machine')
      autoload :StartMachine, action_root.join('start_machine')
      autoload :StopMachine, action_root.join('stop_machine')
      autoload :WaitForIpAddress, action_root.join('wait_for_ip_address')
    end
  end
end
