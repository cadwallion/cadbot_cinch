require 'cinch'
require './plugin'

bot = Cinch::Bot.new do
  configure do |c|
    c.nick = "CadBotAlpha"
    c.server  = "irc.mmoirc.com"
    c.channels = ["#coding"]
    c.verbose = true
    c.plugins.plugins = [BotSnack, Weather, Seen, PastieCmd, Google]
  end
end

bot.start