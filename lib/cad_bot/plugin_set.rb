require 'ostruct'
class CadBot
  class PluginSet
    attr_accessor :plugins, :prefix, :suffix, :path
    
    def initialize
      @plugins  = []
      @prefix   = "@"
      @suffix   = nil
      @path     = CadBot.root + "/plugins/"
    end
    
    def load_plugins(reset = true)
      @plugins = [] if reset
      
      Dir[@path + "/**/*.rb"].each do |file|
        load_plugin(file)
      end
    end
    
    def load_plugin(file)
      plugin = File.basename(file).sub(".rb","")
      if Object.const_defined?(plugin.camelize.to_sym)
        @plugins.delete(plugin.camelize.constantize)
        Object.class_eval do
          remove_const(plugin.camelize.to_sym)
        end
      end
      load(file)
      plugin_class = plugin.camelize.constantize
      if plugin_class.included_modules.include? Cinch::Plugin
        @plugins << plugin_class
      end
    end
    
    def to_struct
      return OpenStruct.new(:plugins => @plugins, :prefix => @prefix, :suffix => @suffix, :path => @path)
    end
  end
end