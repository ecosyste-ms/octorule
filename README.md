# Octorule

[![Gem Version](https://badge.fury.io/rb/octorule.svg)](https://badge.fury.io/rb/octorule)

A command-line tool to enforce and synchronize GitHub repository settings across your organization.

## Features

- Synchronize repository settings across all repositories in an organization
- Manage repository collaborators and their roles
- Configure branch protection rules
- Synchronize file contents from local files to repositories
- Customizable settings via JSON file
- Filter repositories by name pattern, labels, or language
- Supports pagination for organizations with many repositories
- Detailed logging of operations
- Support for GitHub Enterprise via custom base URL
- Dry-run mode to preview changes

## Prerequisites

- Ruby 3.2 or higher
- GitHub Personal Access Token with `repo` and `admin:org` scopes

## Installation

Install the gem:

```bash
gem install octorule
```

## Usage

Run the tool using:

```bash
octorule --org my-org --settings settings.json [options]
```

### Command Line Arguments

Required Arguments:

- `-o, --org <organization>`: GitHub organization name
- `-s, --settings <path>`: Path to JSON file with repository settings

Authentication Options:

- `-t, --token <token>`: GitHub Personal Access Token (overrides GITHUB_TOKEN env var)
- `-u, --base-url <url>`: GitHub API base URL (for GitHub Enterprise)

Filter Options:

- `-n, --name-pattern <pattern>`: Regular expression pattern to match repository names to include
- `-l, --label <label>`: Only process repositories that have this label
- `--language <language>`: Only process repositories with this primary language
- `--fork`: Only process repositories that are forks
- `--no-fork`: Only process repositories that aren't forks

Other Options:

- `-d, --dry-run`: Show what would be changed without making changes
- `-h, --help`: Show help message
- `-v, --version`: Show version

### Examples

```bash
# Basic usage with environment variables
export GITHUB_TOKEN=ghp_xxxxxxxxxxxx
octorule --org my-org --settings settings.json

# Using CLI token instead of environment variable
octorule --org my-org --settings settings.json --token ghp_xxxxxxxxxxxx

# Dry-run mode to preview changes
octorule --org my-org --settings settings.json --dry-run

# Using GitHub Enterprise
octorule --org my-org --settings settings.json --base-url https://github.enterprise.com/api/v3

# Only process repositories with names containing 'api' or 'service'
octorule --org my-org --settings settings.json --name-pattern "api|service"

# Only process repositories with the 'active' label
octorule --org my-org --settings settings.json --label active

# Only process Ruby repositories
octorule --org my-org --settings settings.json --language ruby

# Only process forked repositories
octorule --org my-org --settings settings.json --fork

# Only process non-forked repositories
octorule --org my-org --settings settings.json --no-fork

# Combine multiple filters (repositories must match ALL specified filters)
octorule --org my-org --settings settings.json --name-pattern "api" --language ruby
```

### Settings File

Create a JSON file with your desired repository settings. Here's an example:

```json
{
  "repository": {
    "has_issues": true,
    "has_wiki": false,
    "has_projects": true,
    "allow_squash_merge": true,
    "allow_merge_commit": false,
    "allow_rebase_merge": true,
    "delete_branch_on_merge": true,
    "allow_auto_merge": true,
    "allow_update_branch": true
  },
  "collaborators": [
    {
      "username": "user1",
      "role": "admin"
    },
    {
      "username": "user2",
      "role": "write"
    }
  ],
  "branch_protection": {
    "main": {
      "enforce_admins": true,
      "required_status_checks": {
        "strict": true,
        "contexts": ["ci/build", "ci/test"]
      },
      "required_pull_request_reviews": {
        "required_approving_review_count": 2,
        "dismiss_stale_reviews": true,
        "require_code_owner_reviews": true
      },
      "allow_force_pushes": false,
      "allow_deletions": false
    }
  },
  "files": [
    {
      "path": ".gitignore",
      "localPath": "./templates/.gitignore"
    },
    {
      "path": "CONTRIBUTING.md",
      "localPath": "./templates/CONTRIBUTING.md"
    }
  ]
}
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ecosyste-ms/octorule. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/ecosyste-ms/octorule/blob/main/CODE_OF_CONDUCT.md).

## License

MIT

## Code of Conduct

Everyone interacting in the Octorule project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/ecosyste-ms/octorule/blob/main/CODE_OF_CONDUCT.md).
