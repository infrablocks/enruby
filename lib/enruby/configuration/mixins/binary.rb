# frozen_string_literal: true

require 'logger'

module Enruby
  module Configuration
    module Mixins
      module Binary
        attr_accessor :binary

        def initialize
          super
          @binary = default_binary
        end

        private

        def default_binary
          raise NotImplementedError
        end
      end
    end
  end
end
