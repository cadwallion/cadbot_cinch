require 'cinch'
require 'yaml'
require 'ostruct'
require File.dirname(__FILE__) + '/extensions'

class CadBot
  attr_accessor :networks, :config, :plugin_path
  attr_reader :plugins
  
  NETWORK_DEFAULTS = {
    "server"  => "127.0.0.1",
    "port"    => 6667,
    "nick"    => "CadBot",
    "user"    => "cadbot",
    "realname"=> "cadbot"
  }
  
  class PluginSet
    attr_accessor :plugins, :prefix, :suffix, :path
    
    def initialize
      @plugins  = []
      @prefix   = "@"
      @suffix   = nil
      @path     = File.dirname(__FILE__) + "/../plugins/"
    end
    
    def load
      plugins.each do |p|
        load(path + p + ".rb")
      end
    end
    
    def to_struct
      return OpenStruct.new(:plugins => @plugins, :prefix => @prefix, :suffix => @suffix, :path => @path)
    end
  end
  
  def initialize(*args)
    @config = File.open(CadBot.root + "/config/bots.yml", "r") { |f| YAML::load(f) }
    @plugins = CadBot::PluginSet.new
    if @config["plugins"]
      @plugins.prefix = @config["plugins"]["prefix"] if @config["plugins"]["prefix"]
      @plugins.suffix = @config["plugins"]["suffix"] if @config["plugins"]["suffix"]
      @plugins.path   = @config["plugins"]["path"] if @config["plugins"]["path"]
    end
      @networks = {}
    load_plugins
    load_networks
  end
  
  def load_plugins
    Dir[@plugins.path + "*.rb"].each do |file|
      if file =~ /(.*)\/plugins\/(.*)\.rb/
        plugin = $2
        load(@plugins.path + plugin + ".rb")
        @plugins.plugins << plugin.camelize.constantize
      end
    end
  end
  
  def load_networks
    @config["networks"].each do |network|
      @options = NETWORK_DEFAULTS.merge(network)
      puts "options: #{@options}"
      b = Cinch::Bot.new
      @options.each do |key, value|
        b.config.send("#{key}=", value)
      end
      b.config.plugins = @plugins.to_struct
      b.config.verbose   = true
      @networks[network["name"]] = b
    end
  end
  
  def start
    @networks.each do |name, bot|
      pid = fork do
        bot.start
      end
      Process.detach(pid)
      File.open(CadBot.root + name + ".pid", "w+") { |f| f << pid }
    end
  end
  
  def self.root
    @root ||= File.dirname(__FILE__) + "/../"
  end
end