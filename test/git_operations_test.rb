# frozen_string_literal: true

require_relative 'test_helper'

class GitOperationsTest < Minitest::Test
  include TestHelpers

  def setup
    @config = setup_temp_workspace
    @git_ops = SocketryManager::GitOperations.new(@config)
  end

  def teardown
    teardown_temp_workspace
  end

  def test_finds_all_repos_in_categories
    create_mock_repo('async', '01-async-core')
    create_mock_repo('async-http', '02-http-web')
    create_mock_repo('falcon', '04-frameworks')

    repos = @git_ops.find_all_repos

    assert_equal 3, repos.size
    assert_includes repos.map { |r| r[:name] }, 'async'
    assert_includes repos.map { |r| r[:name] }, 'async-http'
    assert_includes repos.map { |r| r[:name] }, 'falcon'
  end

  def test_finds_repos_with_correct_categories
    create_mock_repo('async', '01-async-core')
    create_mock_repo('async-http', '02-http-web')

    repos = @git_ops.find_all_repos

    async_repo = repos.find { |r| r[:name] == 'async' }
    http_repo = repos.find { |r| r[:name] == 'async-http' }

    assert_equal '01-async-core', async_repo[:category]
    assert_equal '02-http-web', http_repo[:category]
  end

  def test_finds_repos_with_paths
    async_path = create_mock_repo('async', '01-async-core')
    http_path = create_mock_repo('async-http', '02-http-web')

    repos = @git_ops.find_all_repos

    async_repo = repos.find { |r| r[:name] == 'async' }
    http_repo = repos.find { |r| r[:name] == 'async-http' }

    assert_equal async_path, async_repo[:path]
    assert_equal http_path, http_repo[:path]
  end

  def test_finds_no_repos_in_empty_workspace
    repos = @git_ops.find_all_repos

    assert_equal 0, repos.size
  end

  def test_skips_directories_without_git
    category_dir = File.join(@temp_dir, '01-async-core')
    FileUtils.mkdir_p(category_dir)
    non_git_dir = File.join(category_dir, 'not-a-repo')
    FileUtils.mkdir_p(non_git_dir)

    repos = @git_ops.find_all_repos

    assert_equal 0, repos.size
  end

  def test_clone_repository_returns_skipped_if_exists
    target_dir = File.join(@temp_dir, 'unsorted')
    FileUtils.mkdir_p(File.join(target_dir, 'async', '.git'))

    status = @git_ops.clone_repository('https://example.com/async.git', 'async', target_dir)

    assert_equal :skipped, status
  end
end
