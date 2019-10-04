module Murcure
  class ClientState
    include AASM

    def initialize
      @operations = [] of Symbol
    end

    def has_auth?
      @operations.include?(:add_auth)
    end

    def has_version?
      @operations.include?(:add_version)
    end

    def channels_sent?
      @operations.include?(:channels_sent)
    end

    def users_sent?
      @operations.include?(:users_sent)
    end

    def synchonized?
      channels_sent? && users_sent?
    end

    def act_as_state_machine
      aasm.state :connected, initial: true
      aasm.state :sync, guard: -> { has_auth? && has_version? }
      
      aasm.event :add_version do |e|
        e.before { @operations << :add_version }
        e.transitions from: :connected, to: :sync
      end

      aasm.event :add_auth do |e|
        e.before { @operations << :add_auth }
        e.transitions from: :connected, to: :sync
      end

      aasm.state :active, guard: -> { synchonized? }

      aasm.event :channels_sent do |e|
        e.before { @operations << :channels_sent }
        e.transitions from: :sync, to: :active
      end

      aasm.event :users_sent do |e|
        e.before { @operations << :users_sent }
        e.transitions from: :sync, to: :active
      end

    end
  end
end
