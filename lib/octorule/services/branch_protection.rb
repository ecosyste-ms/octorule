# frozen_string_literal: true

module Octorule
  module Services
    class BranchProtection
      def initialize(client)
        @client = client
      end

      def update(org, repo, branch, settings, dry_run: false)
        if dry_run
          puts "Would update branch protection for #{branch} in #{repo}:"
          settings.each { |k, v| puts "    #{k}: #{v}" }
        else
          @client.protect_branch("#{org}/#{repo}", branch, settings)
          puts "Successfully updated branch protection for #{branch} in #{repo}"
        end
      rescue Octokit::Error => e
        warn "Failed to update branch protection for #{branch} in #{repo}: #{e.message}"
      end
    end
  end
end
