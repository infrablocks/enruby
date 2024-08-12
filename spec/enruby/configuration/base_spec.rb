# frozen_string_literal: true

require 'spec_helper'

require 'tempfile'

RSpec::Matchers.define_negated_matcher(:exclude, :include)

module Test
  class Configuration < Enruby::Configuration::Base
    def default_binary
      'some-binary'
    end
  end
end

describe Enruby::Configuration::Base do
  describe 'binary' do
    it 'raises a NotImplementedError if the default_binary is not overridden' do
      configuration_class = Class.new(described_class)

      expect { configuration_class.new }.to(raise_error(NotImplementedError))
    end

    it 'uses the binary specified in default_binary when overridden' do
      configuration_class = Class.new(Enruby::Configuration::Base) do
        def default_binary
          'test-binary'
        end
      end
      configuration = configuration_class.new

      expect(configuration.binary).to(eq('test-binary'))
    end

    it 'allows the binary to be overridden via attribute writer' do
      configuration_class = Class.new(Test::Configuration)
      configuration = configuration_class.new

      configuration.binary = '/some/specific/binary'

      expect(configuration.binary).to(eq('/some/specific/binary'))
    end
  end

  describe 'streams' do
    describe 'stdout' do
      # rubocop:disable Style/GlobalStdStream
      it 'uses STDOUT as stdout by default' do
        configuration_class = Class.new(Test::Configuration)
        configuration = configuration_class.new

        expect(configuration.stdout).to(eq(STDOUT))
      end
      # rubocop:enable Style/GlobalStdStream

      it 'allows stdout to be overridden via $stdout global' do
        stdout = Tempfile.new
        with_global_stdout(stdout) do
          configuration_class = Class.new(Test::Configuration)
          configuration = configuration_class.new

          expect(configuration.stdout).to(eq(stdout))
        end
      end

      it 'allows stdout to be overridden via attribute writer' do
        stdout = Tempfile.new

        configuration_class = Class.new(Test::Configuration)
        configuration = configuration_class.new

        configuration.stdout = stdout

        expect(configuration.stdout).to(eq(stdout))
      end
    end

    describe 'stderr' do
      # rubocop:disable Style/GlobalStdStream
      it 'uses STDERR as stderr by default' do
        configuration_class = Class.new(Test::Configuration)
        configuration = configuration_class.new

        expect(configuration.stderr).to(eq(STDERR))
      end
      # rubocop:enable Style/GlobalStdStream

      it 'allows stderr to be overridden via $stderr global' do
        stderr = Tempfile.new
        with_global_stderr(stderr) do
          configuration_class = Class.new(Test::Configuration)
          configuration = configuration_class.new

          expect(configuration.stderr).to(eq(stderr))
        end
      end

      it 'allows stderr to be overridden via attribute writer' do
        stderr = Tempfile.new

        configuration_class = Class.new(Test::Configuration)
        configuration = configuration_class.new

        configuration.stderr = stderr

        expect(configuration.stderr).to(eq(stderr))
      end
    end

    describe 'stdin' do
      it 'uses nil as stdin by default' do
        configuration_class = Class.new(Test::Configuration)
        configuration = configuration_class.new

        expect(configuration.stdin).to(be_nil)
      end

      it 'allows stdin to be overridden via attribute writer' do
        stdin = Tempfile.new

        configuration_class = Class.new(Test::Configuration)
        configuration = configuration_class.new

        configuration.stdin = stdin

        expect(configuration.stdin).to(eq(stdin))
      end
    end
  end

  describe 'logging' do
    it 'logs to $stdout at INFO level by default' do
      stdout = Tempfile.new
      configuration_class = Class.new(Test::Configuration)

      with_global_stdout(stdout) do
        configuration = configuration_class.new

        configuration.logger.unknown('UNKNOWN')
        configuration.logger.fatal('FATAL')
        configuration.logger.error('ERROR')
        configuration.logger.warn('WARN')
        configuration.logger.info('INFO')
        configuration.logger.debug('DEBUG')
      end

      stdout.rewind

      expect(stdout.read)
        .to(include('UNKNOWN')
              .and(include('FATAL')
                     .and(include('ERROR')
                            .and(include('WARN')
                                   .and(include('INFO')
                                          .and(exclude('DEBUG')))))))
    end

    it 'allows logger to be overridden via attribute writer' do
      log_target = Tempfile.new
      logger = Logger.new(log_target)
      logger.level = Logger::WARN

      configuration_class = Class.new(Test::Configuration)
      configuration = configuration_class.new

      configuration.logger = logger

      configuration.logger.unknown('UNKNOWN')
      configuration.logger.fatal('FATAL')
      configuration.logger.error('ERROR')
      configuration.logger.warn('WARN')
      configuration.logger.info('INFO')
      configuration.logger.debug('DEBUG')

      log_target.rewind

      expect(log_target.read)
        .to(include('UNKNOWN')
              .and(include('FATAL')
                     .and(include('ERROR')
                            .and(include('WARN')
                                   .and(exclude('INFO')
                                          .and(exclude('DEBUG')))))))
    end
  end
end

def with_global_stderr(io, &block)
  stderr = $stderr
  begin
    $stderr = io
    block.call
  ensure
    $stderr = stderr
  end
end

def with_global_stdout(io, &block)
  stdout = $stdout
  begin
    $stdout = io
    block.call
  ensure
    $stdout = stdout
  end
end
