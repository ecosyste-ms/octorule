# frozen_string_literal: true

module Octorule
  module Services
    class Repository
      def initialize(client)
        @client = client
      end

      def fetch_all(org)
        repos = []
        page = 1

        loop do
          response = @client.org_repos(org, per_page: 100, page: page)
          break if response.empty?

          repos.concat(response)
          page += 1
        end

        repos
      end

      def update_settings(org, repo, settings, dry_run: false)
        return unless settings["repository"]

        current = fetch_settings(org, repo)
        return unless current

        diff = settings_diff(current, settings["repository"])

        if diff.empty?
          puts "Skipping #{repo} - settings match"
          return
        end

        if dry_run
          puts "Would update repository settings for #{repo}:"
          diff.each { |k, v| puts "    #{k}: #{v}" }
        else
          @client.edit_repository("#{org}/#{repo}", diff)
          puts "Successfully updated settings for #{repo}"
        end
      rescue Octokit::Error => e
        warn "Failed to update settings for #{repo}: #{e.message}"
      end

      private

      def fetch_settings(org, repo)
        @client.repository("#{org}/#{repo}")
      rescue Octokit::Error => e
        warn "Failed to fetch settings for #{repo}: #{e.message}"
        nil
      end

      def settings_diff(current, desired)
        diff = {}
        desired.each do |key, value|
          current_value = current[key.to_sym]
          diff[key] = value unless current_value == value
        end
        diff
      end
    end
  end
end
