# frozen_string_literal: true

require_relative "octorule/version"
require "octokit"

module Octorule
  class Error < StandardError; end

  autoload :CLI, "octorule/cli"
  autoload :Syncer, "octorule/syncer"
  autoload :Filters, "octorule/filters"

  module Services
    autoload :Repository, "octorule/services/repository"
    autoload :Collaborators, "octorule/services/collaborators"
    autoload :BranchProtection, "octorule/services/branch_protection"
    autoload :FileSync, "octorule/services/file_sync"
  end
end
