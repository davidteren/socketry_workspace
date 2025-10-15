require_relative 'test_helper'

class MetadataManagerTest < Minitest::Test
  include TestHelpers

  def setup
    @config = setup_temp_workspace
    @metadata_mgr = SocketryManager::MetadataManager.new(@config)
  end

  def teardown
    teardown_temp_workspace
  end

  def test_generates_metadata_with_categories_and_repos
    create_mock_repo('async', '01-async-core')
    create_mock_repo('async-http', '02-http-web')
    
    metadata = @metadata_mgr.generate
    
    assert_equal 'socketry', metadata['org']
    assert metadata['generated_at']
    assert_equal 1, metadata['categories']['01-async-core']['count']
    assert_equal 1, metadata['categories']['02-http-web']['count']
    assert_equal '01-async-core', metadata['repositories']['async']['category']
    assert_equal true, metadata['repositories']['async']['enabled']
  end

  def test_refresh_dependencies_extracts_org_deps
    create_mock_repo('async', '01-async-core')
    http_dir = create_mock_repo('async-http', '02-http-web')
    
    create_mock_gemspec(http_dir, 'async-http', ['async', 'console'])
    
    @metadata_mgr.generate
    metadata = @metadata_mgr.refresh_dependencies
    
    assert_includes metadata['repositories']['async-http']['dependencies'], 'async'
    refute_includes metadata['repositories']['async-http']['dependencies'], 'console'
  end

  def test_respects_enabled_flag
    create_mock_repo('async', '01-async-core')
    create_mock_repo('flappy-bird', '99-miscellaneous')
    
    metadata = @metadata_mgr.generate
    metadata['repositories']['flappy-bird']['enabled'] = false
    @metadata_mgr.save(metadata)
    
    enabled_repos = @metadata_mgr.enabled_repositories
    
    assert_includes enabled_repos.map { |r| r[:name] }, 'async'
    refute_includes enabled_repos.map { |r| r[:name] }, 'flappy-bird'
  end
end
