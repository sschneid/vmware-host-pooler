# frozen_string_literal: true

require 'rubygems' unless defined?(Gem)
require 'statsd'

module Vmpooler
  class Metrics
    class Statsd < Metrics
      attr_reader :server, :port, :prefix

      # rubocop:disable Lint/MissingSuper
      def initialize(logger, params = {})
        raise ArgumentError, "Statsd server is required. Config: #{params.inspect}" if params['server'].nil? || params['server'].empty?

        host    = params['server']
        @port   = params['port'] || 8125
        @prefix = params['prefix'] || 'vmpooler'
        @server = ::Statsd.new(host, @port)
        @logger = logger
      end
      # rubocop:enable Lint/MissingSuper

      def increment(label)
        server.increment("#{prefix}.#{label}")
      rescue StandardError => e
        @logger.log('s', "[!] Failure incrementing #{prefix}.#{label} on statsd server [#{server}:#{port}]: #{e}")
      end

      def gauge(label, value)
        server.gauge("#{prefix}.#{label}", value)
      rescue StandardError => e
        @logger.log('s', "[!] Failure updating gauge #{prefix}.#{label} on statsd server [#{server}:#{port}]: #{e}")
      end

      def timing(label, duration)
        server.timing("#{prefix}.#{label}", duration)
      rescue StandardError => e
        @logger.log('s', "[!] Failure updating timing #{prefix}.#{label} on statsd server [#{server}:#{port}]: #{e}")
      end
    end
  end
end
