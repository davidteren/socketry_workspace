# frozen_string_literal: true

require_relative 'test_helper'

class CategorizerTest < Minitest::Test
  include TestHelpers

  def setup
    @config = setup_temp_workspace
    @categorizer = SocketryManager::Categorizer.new(@config)
  end

  def teardown
    teardown_temp_workspace
  end

  def test_categorizes_async_core_repos
    assert_equal '01-async-core', @categorizer.categorize('async')
    assert_equal '01-async-core', @categorizer.categorize('async-actor')
    assert_equal '01-async-core', @categorizer.categorize('async-bus')
  end

  def test_categorizes_http_web_repos
    assert_equal '02-http-web', @categorizer.categorize('async-http')
    assert_equal '02-http-web', @categorizer.categorize('async-http-cache')
  end

  def test_defaults_to_miscellaneous
    assert_equal '99-miscellaneous', @categorizer.categorize('unknown-repo')
  end

  def test_categorizes_in_order_of_patterns
    # The first matching pattern wins
    assert_equal '01-async-core', @categorizer.categorize('async')
  end

  def test_organize_repositories_moves_misplaced_repos
    # Create a repo in wrong category
    create_mock_repo('async', '02-http-web')

    results = @categorizer.organize_repositories(dry_run: false)

    assert_equal 1, results[:moved]
    refute Dir.exist?(File.join(@temp_dir, '02-http-web', 'async'))
    assert Dir.exist?(File.join(@temp_dir, '01-async-core', 'async'))
  end

  def test_organize_repositories_keeps_correct_repos
    # Create a repo in correct category
    create_mock_repo('async', '01-async-core')

    results = @categorizer.organize_repositories(dry_run: false)

    assert_equal 0, results[:moved]
    assert Dir.exist?(File.join(@temp_dir, '01-async-core', 'async'))
  end

  def test_organize_repositories_dry_run_doesnt_move
    create_mock_repo('async', '02-http-web')

    results = @categorizer.organize_repositories(dry_run: true)

    assert_equal 1, results[:moved]
    assert Dir.exist?(File.join(@temp_dir, '02-http-web', 'async'))
    refute Dir.exist?(File.join(@temp_dir, '01-async-core', 'async'))
  end

  def test_organize_handles_multiple_repos
    create_mock_repo('async', '02-http-web')
    create_mock_repo('async-http', '01-async-core')
    create_mock_repo('unknown-repo', '01-async-core')

    results = @categorizer.organize_repositories(dry_run: false)

    # All 3 repos should be moved to their correct categories
    assert_equal 3, results[:moved]

    # Verify they're in the right places
    assert Dir.exist?(File.join(@temp_dir, '01-async-core', 'async'))
    assert Dir.exist?(File.join(@temp_dir, '02-http-web', 'async-http'))
    assert Dir.exist?(File.join(@temp_dir, '99-miscellaneous', 'unknown-repo'))
  end

  def test_organize_moves_from_unsorted
    # Place a repo into unsorted; categorizer should move it into proper category
    create_unsorted_repo('async')

    results = @categorizer.organize_repositories(dry_run: false)

    assert_equal 1, results[:moved]
    assert Dir.exist?(File.join(@temp_dir, '01-async-core', 'async'))
    refute Dir.exist?(File.join(@temp_dir, 'unsorted', 'async'))
  end
end
