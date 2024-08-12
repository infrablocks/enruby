# frozen_string_literal: true

require 'logger'

module Enruby
  module Configuration
    module Mixins
      module Logging
        attr_accessor :logger

        def initialize
          super
          @logger = default_logger
        end

        def default_logger
          logger = Logger.new($stdout)
          logger.level = Logger::INFO
          logger
        end
      end
    end
  end
end
