# frozen_string_literal: true

module SocketryManager
  class Categorizer
    def initialize(config)
      @config = config
    end

    def categorize(repo_name)
      @config.categories.keys.sort.each do |category|
        patterns = @config.categories[category]
        patterns.each do |pattern|
          return category if repo_name.match?(Regexp.new(pattern))
        end
      end
      '99-miscellaneous'
    end

    def organize_repositories(dry_run: false)
      results = { moved: 0, kept: 0, errors: [] }
      git_ops = GitOperations.new(@config)
      repos = git_ops.find_all_repos

      repos.each do |repo|
        target_category = categorize(repo[:name])
        next if repo[:category] == target_category

        target_dir = File.join(@config.base_dir, target_category)
        FileUtils.mkdir_p(target_dir) unless dry_run

        if dry_run
          puts "[DRY] Would move #{repo[:name]} -> #{target_category}/"
          results[:moved] += 1
        else
          begin
            FileUtils.mv(repo[:path], File.join(target_dir, repo[:name]))
            puts "Moved #{repo[:name]} -> #{target_category}/"
            results[:moved] += 1
          rescue StandardError => e
            results[:errors] << "Failed to move #{repo[:name]}: #{e.message}"
          end
        end
      end

      results
    end
  end
end
