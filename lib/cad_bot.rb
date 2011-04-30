require 'cinch'
require 'yaml'
require 'ostruct'
require 'redis'
require "bundler/setup"

require File.dirname(__FILE__) + "/extensions"
require File.dirname(__FILE__) + "/cad_bot/database"
require File.dirname(__FILE__) + "/cad_bot/plugin_set"
require File.dirname(__FILE__) + "/cad_bot/version"

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
  
  def initialize(options = {})
    config_file = options[:config_file] || (CadBot.root + "/config/bots.yml")
    
    if File.readable?(config_file)
      @config = File.open(config_file, "r") { |f| YAML::load(f) }
    else
      raise "Could not read configuration file."
    end
    
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
    Dir[@plugins.path + "/**/*.rb"].each do |file|
      plugin = File.basename(file).sub(".rb","")
      if Object.const_defined?(plugin.camelize.to_sym)
        Object.class_eval do
          remove_const(plugin.camelize.to_sym)
        end
      end
      load(file)
      plugin_class = plugin.sub(".rb","").camelize.constantize
      if plugin_class.included_modules.include? Cinch::Plugin
        @plugins.plugins << plugin_class
      end
    end
  end
  
  # @TODO: get the db object into the bot
  def load_networks
    @config["networks"].each do |network|
      @options = NETWORK_DEFAULTS.merge(network)
      
      b = Cinch::Bot.new do
        @logger = Cinch::Logger::FormattedLogger.new(File.open(CadBot.root + "log/#{network}.log", "a+"))
        @database = CadBot::Database.connection # @TODO: hook plugins up
      end
      
      @options.each do |key, value|
        b.config.send("#{key}=", value)
      end
      b.config.plugins = @plugins.to_struct
      b.config.verbose   = false
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
      if ENV['OS'] =~ /Windows/
        bot.start
      else
        pid = fork do
          bot.start
        end
        Process.detach(pid)
        File.open(CadBot.root + name + ".pid", "w+") { |f| f << pid }
      end
    end
  end
  
  def self.root
    @root ||= File.dirname(__FILE__) + "/../"
    @root
  end
end