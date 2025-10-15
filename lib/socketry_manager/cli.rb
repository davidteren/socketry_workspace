# frozen_string_literal: true

module SocketryManager
  class CLI
    def initialize(config)
      @config = config
    end

    def run(args)
      command = args[0]

      case command
      when 'setup'
        setup_all
      when 'update'
        update
      when 'organize'
        organize(dry_run: args.include?('--dry-run'))
      when 'refresh-deps', 'refresh-dependencies'
        refresh_dependencies
      when 'stats'
        display_stats
      when 'metadata'
        generate_metadata
      when 'disable'
        disable_repo(args[1])
      when 'enable'
        enable_repo(args[1])
      when 'list-disabled'
        list_disabled
      when 'help', '--help', '-h', nil
        show_help
      else
        puts "Unknown command: #{command}"
        show_help
        exit 1
      end
    end

    private

    def setup_all
      puts '=' * 50
      puts 'Socketry Repository Collection Setup'
      puts '=' * 50
      puts ''
      puts 'This will clone all non-archived socketry repositories'
      puts 'and organize them into categories.'
      puts ''
      print 'Continue? (y/n) '

      return unless gets.chomp.downcase == 'y'

      puts "\nStep 1/4: Cloning repositories..."
      updater = Updater.new(@config)
      github_api = GithubApi.new(@config.org)
      repos = github_api.fetch_all_repos
      updater.clone_missing(repos.map { |r| r[:name] })

      puts "\nStep 2/4: Organizing into categories..."
      organize

      puts "\nStep 3/4: Generating metadata..."
      generate_metadata

      puts "\nStep 4/4: Refreshing dependencies..."
      refresh_dependencies

      puts "\n#{'=' * 50}"
      puts '✅ Setup Complete!'
      puts '=' * 50
    end

    def update
      puts '=' * 50
      puts 'Updating Socketry Repositories'
      puts '=' * 50
      puts ''

      updater = Updater.new(@config)

      puts 'Updating existing repositories...'
      results = updater.update_all

      puts "\nUpdate Summary:"
      puts "  - Updated: #{results[:updated]}"
      puts "  - Up-to-date: #{results[:up_to_date]}"
      puts "  - Failed: #{results[:failed]}"
      puts "  - No upstream: #{results[:no_upstream]}" if results[:no_upstream].positive?
      puts "  - Disabled (skipped): #{results[:skipped]}" if results[:skipped].positive?

      puts "\nChecking for new repositories..."
      new_repos = updater.check_new_repos

      if new_repos.empty?
        puts '  No new repositories found.'
      else
        puts "  Found #{new_repos.size} new repository/repositories:"
        new_repos.each { |r| puts "    - #{r}" }
      end

      puts "\nRegenerating metadata..."
      generate_metadata

      puts "\n#{'=' * 50}"
      puts '✅ Update complete!'
      puts '=' * 50
    end

    def organize(dry_run: false)
      puts 'Organizing repositories into categories...'
      puts ''

      categorizer = Categorizer.new(@config)
      results = categorizer.organize_repositories(dry_run: dry_run)

      puts ''
      puts "Organization #{'(DRY RUN) ' if dry_run}complete!"
      puts "  - Moved: #{results[:moved]}"
      results[:errors].each { |err| puts "  - Error: #{err}" }
    end

    def refresh_dependencies
      puts 'Refreshing intra-org dependencies...'

      metadata_mgr = MetadataManager.new(@config)
      metadata_mgr.refresh_dependencies

      puts '✓ Refreshed dependencies in .workspace_metadata.json'
    end

    def display_stats
      puts 'Repository Statistics:'
      puts ''

      metadata_mgr = MetadataManager.new(@config)
      metadata = metadata_mgr.load

      categories = metadata['categories'] || {}
      total = 0

      categories.keys.sort.each do |category|
        count = categories[category]['count']
        name = category.gsub(/^\d+-/, '').tr('-', ' ').capitalize
        puts "  - #{name}: #{count} repos"
        total += count
      end

      puts ''
      puts "  Total: #{total} repositories"
    end

    def generate_metadata
      metadata_mgr = MetadataManager.new(@config)
      metadata_mgr.generate
      puts '✓ Generated .workspace_metadata.json'
    end

    def disable_repo(repo_name)
      unless repo_name
        puts 'Error: Please specify a repository name'
        puts 'Usage: ruby socketry.rb disable <repo-name>'
        exit 1
      end

      metadata_mgr = MetadataManager.new(@config)
      metadata_mgr.disable_repository(repo_name)
      puts "✓ Disabled #{repo_name} (will be skipped in updates and can be removed)"
    end

    def enable_repo(repo_name)
      unless repo_name
        puts 'Error: Please specify a repository name'
        puts 'Usage: ruby socketry.rb enable <repo-name>'
        exit 1
      end

      metadata_mgr = MetadataManager.new(@config)
      metadata_mgr.enable_repository(repo_name)
      puts "✓ Enabled #{repo_name} (will be included in updates)"
    end

    def list_disabled
      metadata_mgr = MetadataManager.new(@config)
      metadata = metadata_mgr.load

      disabled = []
      metadata['repositories']&.each do |name, info|
        disabled << name if info['enabled'] == false
      end

      if disabled.empty?
        puts 'No disabled repositories.'
      else
        puts 'Disabled repositories:'
        disabled.sort.each { |name| puts "  - #{name}" }
        puts ''
        puts "Total: #{disabled.size}"
      end
    end

    def show_help
      puts <<~HELP
        Socketry Repository Manager

        Usage: ruby socketry.rb <command> [options]

        Commands:
          setup              Clone and organize all repositories (only enabled ones)
          update             Update all enabled repositories and check for new ones
          organize           Organize repositories into categories
                             --dry-run: preview changes without moving
          refresh-deps       Refresh dependency information in metadata
          stats              Display repository statistics
          metadata           Regenerate workspace metadata
          disable <name>     Disable a repository (skip in updates, can be removed)
          enable <name>      Enable a repository (include in updates)
          list-disabled      List all disabled repositories
          help               Show this help message

        Repository Management:
          Repositories have an 'enabled' flag (default: true) in .workspace_metadata.json
          Disabled repos are skipped during updates and can be safely removed locally

        Environment Variables:
          GITHUB_TOKEN       GitHub API token for higher rate limits
          GH_TOKEN           Alternative GitHub token variable

        Examples:
          ruby socketry.rb setup
          ruby socketry.rb update
          ruby socketry.rb organize --dry-run
          ruby socketry.rb refresh-deps
          ruby socketry.rb disable flappy-bird
          ruby socketry.rb list-disabled
          ruby socketry.rb enable async-http
      HELP
    end
  end
end
