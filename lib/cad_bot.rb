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
  
  def initialize(options = {}, &blk)
    @plugins = CadBot::PluginSet.new
    
    case options[:config_file]
    when false
      config_file = nil
    when nil
      config_file = (CadBot.root + "/config/bots.yml")
    else
      config_file = options[:config_file]
    end
    
    if config_file.nil?
      @config = {}
    else
      if File.readable?(config_file)
        @config = File.open(config_file, "r") { |f| YAML::load(f) }
      else
        raise "Could not read configuration file."
      end
    end
    
    if options[:plugins]
      if options[:plugins] != false
        @config["plugins"] ||= {}
        options[:plugins].each do |k,v|
          @config["plugins"][k.to_s] = v
        end
      end
    end
    
    load_plugins
    
    @networks = {}
    load_database
    load_networks
    
    instance_eval(&blk) if block_given?
  end

  def load_networks
    if @config["networks"]
      @config["networks"].each do |network|
        load_network(network)
      end
    end
  end
  
  def load_network(options = {})
    options = NETWORK_DEFAULTS.merge(options)
    
    b = Cinch::Bot.new do
      @logger = Cinch::Logger::FormattedLogger.new(File.open(CadBot.root + "log/#{options["name"]}.log", "a+"))
      @database = CadBot::Database.connection
    end
  
    options.each do |key, value|
      b.config.send("#{key}=", value)
    end
    
    b.config.plugins = @plugins.to_struct
    @networks[options["name"]] = b
  end
  
  def load_plugins
    if @config["plugins"]
      @plugins.prefix = @config["plugins"]["prefix"] if @config["plugins"]["prefix"]
      @plugins.suffix = @config["plugins"]["suffix"] if @config["plugins"]["suffix"]
      @plugins.path   = @config["plugins"]["path"] if @config["plugins"]["path"]
      @plugins.load_plugins
    end
  end
  
  def load_database
    if @config["database"]
      db = @config["database"]
      conds = {}
      if db["socket"]
        conds[:socket] = db["socket"]
      elsif db[:host] || db["port"]
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