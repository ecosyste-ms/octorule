# frozen_string_literal: true

require "optparse"
require "json"

module Octorule
  class CLI
    def self.run(argv)
      new(argv).run
    end

    def initialize(argv)
      @argv = argv
      @options = {}
    end

    def run
      parse_options

      unless @options[:org]
        warn "Error: Organization name is required. Use --org or set GITHUB_ORG environment variable"
        exit 1
      end

      unless @options[:settings]
        warn "Error: Settings file is required. Use --settings"
        exit 1
      end

      token = @options[:token] || ENV["GITHUB_TOKEN"]
      unless token
        warn "Error: GitHub token is required. Use --token or set GITHUB_TOKEN environment variable"
        exit 1
      end

      settings = load_settings(@options[:settings])

      if settings.empty?
        warn "Error: Settings file is empty"
        exit 1
      end

      filters = {
        name_pattern: @options[:name_pattern],
        label: @options[:label],
        language: @options[:language]
      }

      client = Octokit::Client.new(access_token: token, api_endpoint: @options[:base_url])
      syncer = Syncer.new(client, @options[:org], settings, filters, @options[:dry_run])
      syncer.sync
    rescue StandardError => e
      warn "Error: #{e.message}"
      exit 1
    end

    private

    def parse_options
      OptionParser.new do |opts|
        opts.banner = "Usage: octorule --org ORGANIZATION --settings FILE [options]"

        opts.on("-o", "--org ORGANIZATION", "GitHub organization name") do |org|
          @options[:org] = org
        end

        opts.on("-s", "--settings FILE", "Path to JSON file with repository settings") do |file|
          @options[:settings] = file
        end

        opts.on("-n", "--name-pattern PATTERN", "Regular expression pattern to match repository names") do |pattern|
          @options[:name_pattern] = pattern
        end

        opts.on("-l", "--label LABEL", "Only process repositories with this label") do |label|
          @options[:label] = label
        end

        opts.on("--language LANGUAGE", "Only process repositories with this primary language") do |lang|
          @options[:language] = lang
        end

        opts.on("-t", "--token TOKEN", "GitHub Personal Access Token (overrides GITHUB_TOKEN env var)") do |token|
          @options[:token] = token
        end

        opts.on("-u", "--base-url URL", "GitHub API base URL (for GitHub Enterprise)") do |url|
          @options[:base_url] = url
        end

        opts.on("-d", "--dry-run", "Show what would be changed without making changes") do
          @options[:dry_run] = true
        end

        opts.on("-h", "--help", "Show this help message") do
          puts opts
          exit
        end

        opts.on("-v", "--version", "Show version") do
          puts "octorule #{Octorule::VERSION}"
          exit
        end
      end.parse!(@argv)

      @options[:org] ||= ENV["GITHUB_ORG"]
    end

    def load_settings(file)
      JSON.parse(File.read(file))
    rescue Errno::ENOENT
      raise "Settings file not found: #{file}"
    rescue JSON::ParserError => e
      raise "Invalid JSON in settings file: #{e.message}"
    end
  end
end
