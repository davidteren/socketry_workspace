module SocketryManager
  class Updater
    def initialize(config)
      @config = config
      @git_ops = GitOperations.new(config)
      @github_api = GithubApi.new(config.org)
      @metadata = MetadataManager.new(config)
    end

    def update_all
      results = { updated: 0, up_to_date: 0, failed: 0, no_upstream: 0, skipped: 0 }
      repos = @metadata.enabled_repositories
      now = DateTime.now.iso8601

      repos.each do |repo|
        print "Updating #{repo[:name]}... "
        
        status = @git_ops.update_repository(repo[:path])
        
        case status
        when :updated
          puts "✓ updated"
          results[:updated] += 1
        when :up_to_date
          puts "✓ up-to-date"
          results[:up_to_date] += 1
        when :failed
          puts "✗ failed"
          results[:failed] += 1
        when :no_upstream
          puts "⚠ no upstream"
          results[:no_upstream] += 1
        end

        @metadata.update_repo_timestamps(repo[:name], last_pull_at: now)
      end

      # Count disabled repos
      all_repos = @git_ops.find_all_repos
      results[:skipped] = all_repos.size - repos.size

      results
    end

    def check_new_repos
      current_repos = @github_api.fetch_all_repos
      cloned_repos = @git_ops.find_all_repos.map { |r| r[:name] }
      metadata = @metadata.load

      # Update remote timestamps in metadata
      current_repos.each do |repo|
        # Initialize with enabled: true for new repos
        if metadata.dig('repositories', repo[:name]).nil?
          metadata['repositories'] ||= {}
          metadata['repositories'][repo[:name]] = { 'enabled' => true }
        end
        
        @metadata.update_repo_timestamps(
          repo[:name],
          remote_pushed_at: repo[:pushed_at],
          remote_updated_at: repo[:updated_at]
        )
      end

      new_repos = current_repos.reject { |r| cloned_repos.include?(r[:name]) }
      
      # Filter out disabled repos from new repos list
      enabled_new_repos = new_repos.select do |repo|
        metadata = @metadata.load
        metadata.dig('repositories', repo[:name], 'enabled') != false
      end
      
      enabled_new_repos.map { |r| r[:name] }
    end

    def clone_missing(repos_to_clone, target_dir: nil)
      target_dir ||= File.join(@config.base_dir, 'unsorted')
      FileUtils.mkdir_p(target_dir)

      results = { cloned: 0, skipped: 0, failed: 0 }
      github_repos = @github_api.fetch_all_repos

      repos_to_clone.each do |repo_name|
        repo_info = github_repos.find { |r| r[:name] == repo_name }
        next unless repo_info

        print "Cloning #{repo_name}... "
        status = @git_ops.clone_repository(repo_info[:clone_url], repo_name, target_dir)

        case status
        when :cloned
          puts "✓ cloned"
          results[:cloned] += 1
        when :skipped
          puts "⚠ already exists"
          results[:skipped] += 1
        when :failed
          puts "✗ failed"
          results[:failed] += 1
        end
      end

      results
    end
  end
end
