# frozen_string_literal: true

require 'minitest/autorun'
require 'minitest/pride'
require 'zeitwerk'
require 'fileutils'
require 'tmpdir'

loader = Zeitwerk::Loader.new
loader.push_dir(File.expand_path('../lib', __dir__))
loader.inflector.inflect('cli' => 'CLI')
loader.setup

module TestHelpers
  def setup_temp_workspace
    @temp_dir = Dir.mktmpdir('socketry_test')
    @config = SocketryManager::Configuration.new(@temp_dir)

    # Create categories.json
    categories = {
      '01-async-core' => ['^async$', '^async-(actor|bus)$'],
      '02-http-web' => ['^async-http'],
      '99-miscellaneous' => []
    }
    File.write(@config.categories_file, JSON.pretty_generate(categories))

    @config
  end

  def teardown_temp_workspace
    FileUtils.rm_rf(@temp_dir) if @temp_dir && File.exist?(@temp_dir)
  end

  def create_mock_repo(name, category)
    category_dir = File.join(@temp_dir, category)
    FileUtils.mkdir_p(category_dir)

    repo_dir = File.join(category_dir, name)
    FileUtils.mkdir_p(File.join(repo_dir, '.git'))

    repo_dir
  end

  def create_mock_gemspec(repo_dir, name, dependencies = [])
    gemspec_content = <<~GEMSPEC
      Gem::Specification.new do |spec|
        spec.name = "#{name}"
        spec.version = "1.0.0"
        #{dependencies.map { |dep| "spec.add_dependency '#{dep}'" }.join("\n  ")}
      end
    GEMSPEC

    File.write(File.join(repo_dir, "#{name}.gemspec"), gemspec_content)
  end
end
