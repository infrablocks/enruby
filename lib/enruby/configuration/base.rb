# frozen_string_literal: true

require_relative 'mixins'

module Enruby
  module Configuration
    class Base
      include Mixins::Streams
      include Mixins::Logging
      include Mixins::Binary
    end
  end
end
