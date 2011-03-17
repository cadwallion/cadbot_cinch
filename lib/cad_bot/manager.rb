require 'yaml'
module CadBot
  class Manager
    attr_accessor :bots, :plugins
    
    def initialize
      @bots = []
      detect_plugins
      load_plugins
      load_config
    end
    
    def load_config
      configs = File.open(File.dirname(__FILE__) + "/config.yml", "r") { |f| YAML::load(f) }
      plugin_const = @plugins.map { |plugin| plugin.camelize.constantize }
      configs["networks"].each do |n|
        self.bots << Bot.new(:server_config => n, 
        :plugins => plugin_const)
      end
    end
    
    def detect_plugins
      @plugins = []
      Dir[File.dirname(__FILE__) + "/plugins/*.rb"].each do |file|
        @plugins << file.split("/").last.gsub(".rb","")
      end
    end
    
    def load_plugins
      @plugins.each do |p|
        load(File.dirname(__FILE__) + "/plugins/#{p}.rb")
      end
    end
    
    def run
      bots.each do |b|
        pid = fork do
          b.start
        end
        Process.detach(pid)
        File.open(File.dirname(__FILE__) + "/../../#{b.name}.pid", "w+") { |f| f << pid }
      end
      return
    end
  end
end