# frozen_string_literal: true

require_relative 'test_helper'
require 'open3'

class IntegrationUpdateTest < Minitest::Test
  include TestHelpers

  def setup
    @config = setup_temp_workspace
  end

  def teardown
    teardown_temp_workspace
  end

  def run_cmd(*args, chdir: nil)
    Dir.chdir(chdir || Dir.pwd) do
      out, err, status = Open3.capture3(*args)
      unless status.success?
        flunk("Command failed: #{args.join(' ')}\nStatus: #{status.exitstatus}\nSTDOUT:\n#{out}\nSTDERR:\n#{err}")
      end
      out
    end
  end

  def init_bare_repo(path)
    FileUtils.mkdir_p(path)
    run_cmd('git', 'init', '--bare', path)
  end

  def init_working_repo(path)
    FileUtils.mkdir_p(path)
    # git init -b main may not be available on all systems; try it first
    _, _, status = Open3.capture3('git', 'init', '-b', 'main', path)
    unless status.success?
      # Fallback to default branch then create main
      run_cmd('git', 'init', path)
      run_cmd('git', 'checkout', '-b', 'main', chdir: path)
    end
    path
  end

  def seed_repo_with_commit(path, message: 'initial commit')
    File.write(File.join(path, 'README.md'), "# Repo\n")
    run_cmd('git', 'add', 'README.md', chdir: path)
    run_cmd('git', 'commit', '-m', message, chdir: path)
  end

  def push_to_remote(local_path, remote_path)
    run_cmd('git', 'remote', 'add', 'origin', remote_path, chdir: local_path)
    run_cmd('git', 'push', '-u', 'origin', 'main', chdir: local_path)
  end

  def clone_into_category(remote_path, category, name)
    category_dir = File.join(@config.base_dir, category)
    FileUtils.mkdir_p(category_dir)
    clone_path = File.join(category_dir, name)
    run_cmd('git', 'clone', remote_path, clone_path)
    clone_path
  end

  def test_update_all_pulls_all_repos
    # Setup two bare remotes and seed them with commits
    tmp = Dir.mktmpdir('socketry_git_remotes')
    begin
      remote_a = File.join(tmp, 'remote_a.git')
      remote_b = File.join(tmp, 'remote_b.git')

      init_bare_repo(remote_a)
      init_bare_repo(remote_b)

      working_a = init_working_repo(File.join(tmp, 'work_a'))
      seed_repo_with_commit(working_a, message: 'initial A')
      push_to_remote(working_a, remote_a)

      working_b = init_working_repo(File.join(tmp, 'work_b'))
      seed_repo_with_commit(working_b, message: 'initial B')
      push_to_remote(working_b, remote_b)

      # Clone into our workspace categories to simulate existing repos
      clone_a = clone_into_category(remote_a, '01-async-core', 'async')
      clone_b = clone_into_category(remote_b, '02-http-web', 'async-http')

      # Make remotes ahead by 1 commit each
      File.write(File.join(working_a, 'A.txt'), "A1\n")
      run_cmd('git', 'add', 'A.txt', chdir: working_a)
      run_cmd('git', 'commit', '-m', 'advance A', chdir: working_a)
      run_cmd('git', 'push', 'origin', 'main', chdir: working_a)

      File.write(File.join(working_b, 'B.txt'), "B1\n")
      run_cmd('git', 'add', 'B.txt', chdir: working_b)
      run_cmd('git', 'commit', '-m', 'advance B', chdir: working_b)
      run_cmd('git', 'push', 'origin', 'main', chdir: working_b)

      # Configure upstream tracking for clones if needed
      # Fetch and set upstream to origin/main (for older git clones)
      run_cmd('git', 'fetch', 'origin', chdir: clone_a)
      run_cmd('git', 'branch', '--set-upstream-to', 'origin/main', 'main', chdir: clone_a)

      run_cmd('git', 'fetch', 'origin', chdir: clone_b)
      run_cmd('git', 'branch', '--set-upstream-to', 'origin/main', 'main', chdir: clone_b)

      updater = SocketryManager::Updater.new(@config)

      results = updater.update_all

      # Both repos should be updated
      assert_equal 2, results[:updated]

      # Verify local HEAD matches remote after update
      local_a = run_cmd('git', 'rev-parse', '@', chdir: clone_a).strip
      remote_a_head = run_cmd('git', 'rev-parse', '@{u}', chdir: clone_a).strip

      assert_equal remote_a_head, local_a

      local_b = run_cmd('git', 'rev-parse', '@', chdir: clone_b).strip
      remote_b_head = run_cmd('git', 'rev-parse', '@{u}', chdir: clone_b).strip

      assert_equal remote_b_head, local_b
    ensure
      FileUtils.rm_rf(tmp) if tmp && File.exist?(tmp)
    end
  end
end
