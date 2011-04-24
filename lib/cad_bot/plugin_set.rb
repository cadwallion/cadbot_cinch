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
    
    def load
      plugins.each do |p|
        load(path + p + ".rb")
      end
    end
    
    def to_struct
      return OpenStruct.new(:plugins => @plugins, :prefix => @prefix, :suffix => @suffix, :path => @path)
    end
  end
end