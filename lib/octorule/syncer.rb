# frozen_string_literal: true

module Octorule
  class Syncer
    def initialize(client, org, settings, filters = {}, dry_run = false)
      @client = client
      @org = org
      @settings = settings
      @filters = filters
      @dry_run = dry_run

      @repository_service = Services::Repository.new(client)
      @collaborators_service = Services::Collaborators.new(client)
      @branch_protection_service = Services::BranchProtection.new(client)
      @file_sync_service = Services::FileSync.new(client)
      @filters_service = Filters.new(client)
    end

    def sync
      puts "Starting settings sync for organization: #{@org}"
      puts "Running in dry-run mode - no changes will be made" if @dry_run

      repos = @repository_service.fetch_all(@org)
      puts "Found #{repos.length} repositories"

      processed_count = 0
      skipped_count = 0

      repos.each do |repo|
        if @filters_service.should_process?(repo, @filters)
          process_repository(repo)
          processed_count += 1
        else
          skipped_count += 1
        end
      end

      puts "Settings sync completed!"
      puts "Summary:"
      puts "    - Total repositories: #{repos.length}"
      puts "    - Processed: #{processed_count}"
      puts "    - Skipped: #{skipped_count}"
      puts "    - Mode: #{@dry_run ? "Dry Run" : "Live"}"
    rescue StandardError => e
      warn "Error during sync: #{e.message}"
      raise
    end

    private

    def process_repository(repo)
      repo_name = repo[:name]

      @repository_service.update_settings(@org, repo_name, @settings, dry_run: @dry_run)

      if @settings["collaborators"]
        @collaborators_service.update(@org, repo_name, @settings["collaborators"], dry_run: @dry_run)
        puts "#{@dry_run ? "Would update" : "Successfully updated"} collaborators for #{repo_name}"
      end

      if @settings["branch_protection"]&.is_a?(Hash)
        @settings["branch_protection"].each do |branch, protection|
          @branch_protection_service.update(@org, repo_name, branch, protection, dry_run: @dry_run)
        end
        puts "#{@dry_run ? "Would update" : "Successfully updated"} branch protection for #{repo_name}"
      end

      if @settings["files"]&.is_a?(Array)
        @settings["files"].each do |file_sync|
          @file_sync_service.sync(@org, repo_name, file_sync, dry_run: @dry_run)
        end
        puts "#{@dry_run ? "Would sync" : "Successfully synced"} file content for #{repo_name}"
      end
    end
  end
end
