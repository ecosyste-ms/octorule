# frozen_string_literal: true

module Octorule
  module Services
    class Collaborators
      def initialize(client)
        @client = client
      end

      def update(org, repo, desired_collaborators, dry_run: false)
        current = fetch_collaborators(org, repo)
        current_usernames = current.map { |c| c[:username] }

        desired_collaborators.each do |collaborator|
          username = collaborator["username"]
          role = collaborator["role"]

          if current_usernames.include?(username)
            current_collab = current.find { |c| c[:username] == username }
            if current_collab[:role] != role
              update_role(org, repo, username, role, dry_run)
            end
          else
            add_collaborator(org, repo, username, role, dry_run)
          end
        end
      end

      private

      def fetch_collaborators(org, repo)
        @client.collaborators("#{org}/#{repo}").map do |collab|
          {
            username: collab[:login],
            role: collab[:role_name]
          }
        end
      rescue Octokit::Error => e
        warn "Could not fetch collaborators for #{repo}: #{e.message}"
        []
      end

      def add_collaborator(org, repo, username, role, dry_run)
        if dry_run
          puts "Would add collaborator #{username} with role #{role} to #{repo}"
        else
          @client.add_collaborator("#{org}/#{repo}", username, permission: role)
          puts "Added collaborator #{username} with role #{role} to #{repo}"
        end
      rescue Octokit::Error => e
        warn "Failed to add collaborator #{username} to #{repo}: #{e.message}"
      end

      def update_role(org, repo, username, role, dry_run)
        if dry_run
          puts "Would update role for #{username} to #{role} in #{repo}"
        else
          @client.add_collaborator("#{org}/#{repo}", username, permission: role)
          puts "Updated role for #{username} to #{role} in #{repo}"
        end
      rescue Octokit::Error => e
        warn "Failed to update role for #{username} in #{repo}: #{e.message}"
      end
    end
  end
end
