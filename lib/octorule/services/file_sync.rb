# frozen_string_literal: true

require "base64"

module Octorule
  module Services
    class FileSync
      def initialize(client)
        @client = client
      end

      def sync(org, repo, file_config, dry_run: false)
        path = file_config["path"]
        local_path = file_config["localPath"]

        local_content = File.read(local_path)
        current_file = fetch_file(org, repo, path)

        if current_file && current_file[:content] == local_content
          puts "Skipping #{path} in #{repo} - content matches"
          return
        end

        update_file(org, repo, path, local_content, current_file&.dig(:sha), dry_run)
      rescue Errno::ENOENT
        warn "Local file not found: #{local_path}"
      rescue Octokit::Error => e
        warn "Failed to sync file #{path} in #{repo}: #{e.message}"
      end

      private

      def fetch_file(org, repo, path)
        response = @client.contents("#{org}/#{repo}", path: path)
        {
          content: Base64.decode64(response[:content]),
          sha: response[:sha]
        }
      rescue Octokit::NotFound
        nil
      end

      def update_file(org, repo, path, content, sha, dry_run)
        message = sha ? "Update #{path}" : "Add #{path}"

        if dry_run
          puts "Would #{sha ? "update" : "create"} file #{path} in #{repo}"
          puts "    Content length: #{content.length} characters"
        else
          @client.create_contents(
            "#{org}/#{repo}",
            path,
            message,
            content,
            sha: sha
          )
          puts "Successfully #{sha ? "updated" : "created"} #{path} in #{repo}"
        end
      end
    end
  end
end
