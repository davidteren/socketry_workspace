# frozen_string_literal: true

require_relative 'test_helper'

class UpdaterTest < Minitest::Test
  include TestHelpers

  def setup
    @config = setup_temp_workspace
    @updater = SocketryManager::Updater.new(@config)
  end

  def teardown
    teardown_temp_workspace
  end

  def test_update_all_returns_results_hash
    create_mock_repo('async', '01-async-core')

    results = @updater.update_all

    assert_kind_of Hash, results
    assert_includes results.keys, :updated
    assert_includes results.keys, :up_to_date
    assert_includes results.keys, :failed
    assert_includes results.keys, :no_upstream
    assert_includes results.keys, :skipped
  end

  def test_update_all_skips_disabled_repos
    # Create repos
    create_mock_repo('async', '01-async-core')
    create_mock_repo('flappy-bird', '99-miscellaneous')

    # Disable flappy-bird
    metadata_mgr = SocketryManager::MetadataManager.new(@config)
    metadata_mgr.generate
    metadata_mgr.disable_repository('flappy-bird')

    # Count enabled vs all repos
    git_ops = SocketryManager::GitOperations.new(@config)
    all_repos = git_ops.find_all_repos
    enabled_repos = metadata_mgr.enabled_repositories

    assert_equal 2, all_repos.size
    assert_equal 1, enabled_repos.size
    assert_equal 'async', enabled_repos.first[:name]
  end
end
