# frozen_string_literal: true

require "test_helper"

class TestFilters < Minitest::Test
  def setup
    @client = Minitest::Mock.new
    @filters = Octorule::Filters.new(@client)
  end

  def test_processes_all_repos_when_no_filters
    repo = { name: "test-repo", archived: false }
    assert @filters.should_process?(repo, {})
  end

  def test_skips_archived_repos
    repo = { name: "test-repo", archived: true }
    refute @filters.should_process?(repo, { name_pattern: ".*" })
  end

  def test_filters_by_name_pattern
    repo = { name: "api-service", archived: false }
    assert @filters.should_process?(repo, { name_pattern: "api" })
    refute @filters.should_process?(repo, { name_pattern: "frontend" })
  end

  def test_filters_by_language
    repo = { name: "test-repo", archived: false, language: "Ruby" }
    assert @filters.should_process?(repo, { language: "ruby" })
    refute @filters.should_process?(repo, { language: "python" })
  end

  def test_filters_fork_only
    fork_repo = { name: "forked-repo", archived: false, fork: true }
    regular_repo = { name: "regular-repo", archived: false, fork: false }

    assert @filters.should_process?(fork_repo, { fork: true })
    refute @filters.should_process?(regular_repo, { fork: true })
  end

  def test_filters_no_fork
    fork_repo = { name: "forked-repo", archived: false, fork: true }
    regular_repo = { name: "regular-repo", archived: false, fork: false }

    refute @filters.should_process?(fork_repo, { fork: false })
    assert @filters.should_process?(regular_repo, { fork: false })
  end
end
