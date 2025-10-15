# frozen_string_literal: true

require 'net/http'
require 'uri'

module SocketryManager
  class GithubApi
    def initialize(org, token: nil)
      @org = org
      @token = token || ENV['GITHUB_TOKEN'] || ENV.fetch('GH_TOKEN', nil)
    end

    def fetch_all_repos
      repos = []
      page = 1

      loop do
        response = fetch_page(page)
        break if response.empty?

        non_archived = response.reject { |repo| repo['archived'] }
        repos.concat(non_archived.map do |repo|
          {
            name: repo['name'],
            clone_url: repo['clone_url'],
            pushed_at: repo['pushed_at'],
            updated_at: repo['updated_at']
          }
        end)

        page += 1
      end

      repos
    end

    private

    def fetch_page(page)
      uri = URI("https://api.github.com/orgs/#{@org}/repos?per_page=100&page=#{page}")
      request = Net::HTTP::Get.new(uri)
      request['Accept'] = 'application/vnd.github+json'
      request['Authorization'] = "Bearer #{@token}" if @token

      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        http.request(request)
      end

      return [] unless response.is_a?(Net::HTTPSuccess)

      JSON.parse(response.body)
    rescue StandardError => e
      warn "Error fetching GitHub API: #{e.message}"
      []
    end
  end
end
