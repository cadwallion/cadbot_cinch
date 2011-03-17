require './plugins/bot_snack'
require './plugins/weather'
require './plugins/seen'
require './plugins/pastie'
require './plugins/google'

module CadBot
  class Plugin
    include Cinch::Plugin
    prefix "@"
  end
end
