# frozen_string_literal: true

require_relative 'test_helper'

class ConfigurationTest < Minitest::Test
  include TestHelpers

  def setup
    @config = setup_temp_workspace
  end

  def teardown
    teardown_temp_workspace
  end

  def test_initializes_with_base_dir
    assert_equal @temp_dir, @config.base_dir
  end

  def test_has_default_org
    assert_equal 'socketry', @config.org
  end

  def test_loads_categories_from_json
    categories = @config.categories

    assert_includes categories, '01-async-core'
    assert_includes categories, '02-http-web'
    assert_equal ['^async$', '^async-(actor|bus)$'], categories['01-async-core']
  end

  def test_returns_empty_hash_when_no_categories_file
    FileUtils.rm(@config.categories_file)
    config = SocketryManager::Configuration.new(@temp_dir)

    assert_empty(config.categories)
  end

  def test_categories_file_path
    expected_path = File.join(@temp_dir, 'categories.json')

    assert_equal expected_path, @config.categories_file
  end

  def test_workspace_metadata_file_path
    expected_path = File.join(@temp_dir, '.workspace_metadata.json')

    assert_equal expected_path, @config.workspace_metadata_file
  end
end
