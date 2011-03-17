module CadBot
  class Bot < Cinch::Bot
    attr_accessor :name
    def initialize(args)
      super()
      configure do |c|
        args[:server_config].each do |key, value|
          c.send("#{key}=", value)
        end
        @name = args[:server_config]["name"]
        c.plugins.plugins = args[:plugins]
      end
    end
  end
end