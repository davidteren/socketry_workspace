# frozen_string_literal: true

require 'json'
require 'fileutils'
require 'open3'
require 'date'

module SocketryManager
  class Error < StandardError; end
end
