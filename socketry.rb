#!/usr/bin/env ruby
# frozen_string_literal: true

require 'zeitwerk'

loader = Zeitwerk::Loader.new
loader.push_dir(File.expand_path('lib', __dir__))
loader.inflector.inflect('cli' => 'CLI')
loader.setup

config = SocketryManager::Configuration.new(File.expand_path(__dir__))
cli = SocketryManager::CLI.new(config)
cli.run(ARGV)
