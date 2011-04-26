require 'cinch'
require 'yaml'
require 'ostruct'
require 'redis'
require File.dirname(__FILE__) + "/extensions"
require File.dirname(__FILE__) + "/cad_bot/database"
require File.dirname(__FILE__) + "/cad_bot/plugin_set"

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
  
  def initialize(*args)
    @config = File.open(CadBot.root + "/config/bots.yml", "r") { |f| YAML::load(f) }
    @plugins = CadBot::PluginSet.new
    if @config["plugins"]
      @plugins.prefix = @config["plugins"]["prefix"] if @config["plugins"]["prefix"]
      @plugins.suffix = @config["plugins"]["suffix"] if @config["plugins"]["suffix"]
      @plugins.path   = @config["plugins"]["path"] if @config["plugins"]["path"]
    end
    @networks = {}
    load_database
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
  
  # @TODO: get the db object into the bot
  def load_networks
    @config["networks"].each do |network|
      @options = NETWORK_DEFAULTS.merge(network)
      puts "options: #{@options}"
      
      b = Cinch::Bot.new do
        @database = CadBot::Database.connection # @TODO: hook plugins up
      end
      
      @options.each do |key, value|
        b.config.send("#{key}=", value)
      end
      b.config.plugins = @plugins.to_struct
      b.config.verbose   = true
      @networks[network["name"]] = b
    end
  end
  
  def load_database
    if @config["database"]
      db = @config["database"]
      conds = {}
      if db["socket"]
        conds[:socket] = db["socket"]
      elsif db["host"] || db["port"]
        conds[:host] = db["host"] || "127.0.0.1"
        conds[:port] = db["port"] || "6379"
      end
      CadBot::Database.load(conds)
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