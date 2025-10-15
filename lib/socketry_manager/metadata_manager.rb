# frozen_string_literal: true

module SocketryManager
  class MetadataManager
    def initialize(config)
      @config = config
    end

    def load
      return {} unless File.exist?(@config.workspace_metadata_file)

      JSON.parse(File.read(@config.workspace_metadata_file))
    end



    def save(data)
      File.write(@config.workspace_metadata_file, JSON.pretty_generate(data))
    end

    def generate
      git_ops = GitOperations.new(@config)
      repos = git_ops.find_all_repos

      metadata = load
      repositories = metadata['repositories'] || {}
      categories = Hash.new { |h, k| h[k] = { 'count' => 0 } }

      repos.each do |repo|
        categories[repo[:category]]['count'] += 1

        repositories[repo[:name]] ||= {}
        repositories[repo[:name]]['category'] = repo[:category]
        repositories[repo[:name]]['enabled'] =
          repositories[repo[:name]]['enabled'].nil? || repositories[repo[:name]]['enabled']
        repositories[repo[:name]]['description'] = repositories[repo[:name]]['description'] || ''
        repositories[repo[:name]]['dependencies'] ||= []
      end

      result = {
        'generated_at' => DateTime.now.iso8601,
        'org' => @config.org,
        'categories' => categories,
        'repositories' => repositories
      }

      save(result)
      result
    end

    def enabled_repositories
      git_ops = GitOperations.new(@config)
      all_repos = git_ops.find_all_repos
      metadata = load

      all_repos.select do |repo|
        repo_metadata = metadata.dig('repositories', repo[:name])
        repo_metadata.nil? || repo_metadata['enabled'] != false
      end
    end

    def disable_repository(repo_name)
      metadata = load
      metadata['repositories'] ||= {}
      metadata['repositories'][repo_name] ||= {}
      metadata['repositories'][repo_name]['enabled'] = false
      save(metadata)
    end

    def enable_repository(repo_name)
      metadata = load
      metadata['repositories'] ||= {}
      metadata['repositories'][repo_name] ||= {}
      metadata['repositories'][repo_name]['enabled'] = true
      save(metadata)
    end

    def update_repo_timestamps(repo_name, last_pull_at: nil, remote_pushed_at: nil, remote_updated_at: nil)
      metadata = load
      metadata['repositories'] ||= {}
      metadata['repositories'][repo_name] ||= {}

      metadata['repositories'][repo_name]['last_pull_at'] = last_pull_at if last_pull_at
      metadata['repositories'][repo_name]['remote_pushed_at'] = remote_pushed_at if remote_pushed_at
      metadata['repositories'][repo_name]['remote_updated_at'] = remote_updated_at if remote_updated_at

      save(metadata)
    end

    def refresh_dependencies
      git_ops = GitOperations.new(@config)
      repos = git_ops.find_all_repos

      # Build list of all gem names
      all_gems = repos.map { |r| r[:name] }

      metadata = load
      metadata['repositories'] ||= {}

      repos.each do |repo|
        gemspec_file = find_gemspec(repo[:path])
        next unless gemspec_file

        deps = extract_dependencies(gemspec_file, all_gems)
        metadata['repositories'][repo[:name]] ||= {}
        metadata['repositories'][repo[:name]]['dependencies'] = deps
      end

      metadata['generated_at'] = DateTime.now.iso8601
      save(metadata)

      metadata
    end

    private

    def find_gemspec(repo_path)
      Dir.glob(File.join(repo_path, '*.gemspec')).first
    end

    def extract_dependencies(gemspec_file, org_gems)
      return [] unless File.exist?(gemspec_file)

      content = File.read(gemspec_file)
      deps = []

      content.scan(/add(?:_development)?_dependency\s+['"]([^'"]+)['"]/) do |match|
        gem_name = match[0]
        deps << gem_name if org_gems.include?(gem_name)
      end

      deps.uniq.sort
    end
  end
end
