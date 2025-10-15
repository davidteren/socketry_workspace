# frozen_string_literal: true

require_relative 'test_helper'

class GithubApiTest < Minitest::Test
  def test_initializes_with_org
    api = SocketryManager::GithubApi.new('socketry')

    assert_equal 'socketry', api.instance_variable_get(:@org)
  end

  def test_initializes_with_token
    api = SocketryManager::GithubApi.new('socketry', token: 'test-token')

    assert_equal 'test-token', api.instance_variable_get(:@token)
  end

  def test_uses_env_token_if_not_provided
    ENV['GITHUB_TOKEN'] = 'env-token'
    api = SocketryManager::GithubApi.new('socketry')

    assert_equal 'env-token', api.instance_variable_get(:@token)
  ensure
    ENV.delete('GITHUB_TOKEN')
  end

  def test_falls_back_to_gh_token_env
    ENV['GH_TOKEN'] = 'gh-token'
    api = SocketryManager::GithubApi.new('socketry')

    assert_equal 'gh-token', api.instance_variable_get(:@token)
  ensure
    ENV.delete('GH_TOKEN')
  end

  # NOTE: We don't test actual API calls to avoid hitting GitHub's API
  # In a real project, you'd use VCR or WebMock for this
end
