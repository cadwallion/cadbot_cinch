require 'cinch'
require './plugins/bot_snack'
require './plugins/weather'
require './plugins/seen'
require './plugins/pastie'

bot = Cinch::Bot.new do
  configure do |c|
    c.nick = "CadBotAlpha"
    c.server  = "irc.mmoirc.com"
    c.channels = ["#coding"]
    c.verbose = true
    c.plugins.plugins = [BotSnack, Weather, Seen, PastieCmd]
  end
end

bot.start