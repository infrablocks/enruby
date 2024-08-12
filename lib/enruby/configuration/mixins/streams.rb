# frozen_string_literal: true

module Enruby
  module Configuration
    module Mixins
      module Streams
        attr_accessor :stdin, :stdout, :stderr

        def initialize
          super
          @stdin = nil
          @stdout = $stdout
          @stderr = $stderr
        end
      end
    end
  end
end
