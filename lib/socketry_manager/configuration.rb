module SocketryManager
  class Configuration
    attr_accessor :base_dir, :org, :categories_file, :workspace_metadata_file

    def initialize(base_dir = Dir.pwd)
      @base_dir = base_dir
      @org = 'socketry'
      @categories_file = File.join(base_dir, 'categories.json')
      @workspace_metadata_file = File.join(base_dir, '.workspace_metadata.json')
    end

    def categories
      @categories ||= load_categories
    end

    private

    def load_categories
      return {} unless File.exist?(categories_file)
      JSON.parse(File.read(categories_file))
    end
  end
end
