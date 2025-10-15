# frozen_string_literal: true

module SocketryManager
  class GitOperations
    def initialize(config)
      @config = config
    end

    def clone_repository(clone_url, name, target_dir)
      return :skipped if Dir.exist?(File.join(target_dir, name, '.git'))

      Dir.chdir(target_dir) do
        _, _, status = Open3.capture3('git', 'clone', clone_url, name)
        status.success? ? :cloned : :failed
      end
    end

    def update_repository(repo_path)
      return :no_git unless Dir.exist?(File.join(repo_path, '.git'))

      Dir.chdir(repo_path) do
        # Check if upstream exists
        _, _, status = Open3.capture3('git', 'rev-parse', '--abbrev-ref', '@{u}')
        return :no_upstream unless status.success?

        # Fetch and check if update needed
        Open3.capture3('git', 'fetch', 'origin', '--quiet')

        local, = Open3.capture3('git', 'rev-parse', '@')
        remote, = Open3.capture3('git', 'rev-parse', '@{u}')

        return :up_to_date if local.strip == remote.strip

        _, _, status = Open3.capture3('git', 'pull', '--quiet')
        status.success? ? :updated : :failed
      end
    end

    def find_all_repos
      category_dirs = Dir.glob(File.join(@config.base_dir, '[0-9]*'))
      unsorted_dir = File.join(@config.base_dir, 'unsorted')
      category_dirs << unsorted_dir if Dir.exist?(unsorted_dir)
      repos = []

      category_dirs.each do |category_dir|
        Dir.glob(File.join(category_dir, '*')).each do |repo_dir|
          next unless Dir.exist?(File.join(repo_dir, '.git'))

          repos << {
            name: File.basename(repo_dir),
            path: repo_dir,
            category: File.basename(category_dir)
          }
        end
      end

      repos
    end
  end
end
