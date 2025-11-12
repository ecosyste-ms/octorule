# frozen_string_literal: true

module Octorule
  class Filters
    def initialize(client)
      @client = client
    end

    def should_process?(repo, filters)
      return true if filters.values.compact.empty?

      if repo[:archived]
        puts "Skipping #{repo[:name]} - repository is archived"
        return false
      end

      if filters[:name_pattern]
        pattern = Regexp.new(filters[:name_pattern])
        unless pattern.match?(repo[:name])
          puts "Skipping #{repo[:name]} - does not match name pattern #{filters[:name_pattern]}"
          return false
        end
      end

      if filters[:language]
        repo_language = repo[:language]&.downcase
        filter_language = filters[:language].downcase
        unless repo_language == filter_language
          puts "Skipping #{repo[:name]} - does not match language #{filters[:language]}"
          return false
        end
      end

      if filters[:label]
        labels = fetch_labels(repo[:owner][:login], repo[:name])
        unless labels.include?(filters[:label])
          puts "Skipping #{repo[:name]} - does not have label #{filters[:label]}"
          return false
        end
      end

      if !filters[:fork].nil?
        if filters[:fork] && !repo[:fork]
          puts "Skipping #{repo[:name]} - repository is not a fork"
          return false
        elsif !filters[:fork] && repo[:fork]
          puts "Skipping #{repo[:name]} - repository is a fork"
          return false
        end
      end

      true
    end

    private

    def fetch_labels(org, repo)
      @client.labels("#{org}/#{repo}").map { |label| label[:name] }
    rescue Octokit::Error => e
      warn "Could not fetch labels for #{repo}: #{e.message}"
      []
    end
  end
end
