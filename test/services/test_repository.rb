# frozen_string_literal: true

require "test_helper"

class TestRepositoryService < Minitest::Test
  def setup
    @client = Minitest::Mock.new
    @service = Octorule::Services::Repository.new(@client)
  end

  def test_fetch_all_paginates
    page1 = [{ name: "repo1" }, { name: "repo2" }]
    page2 = []

    @client.expect(:org_repos, page1) do |org, **kwargs|
      org == "test-org" && kwargs[:per_page] == 100 && kwargs[:page] == 1
    end
    @client.expect(:org_repos, page2) do |org, **kwargs|
      org == "test-org" && kwargs[:per_page] == 100 && kwargs[:page] == 2
    end

    repos = @service.fetch_all("test-org")

    assert_equal 2, repos.length
    assert_equal "repo1", repos[0][:name]
    @client.verify
  end
end
