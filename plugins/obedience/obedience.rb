require 'json'
require 'httparty'
require_relative 'quote'
class Obedience
  include Cinch::Plugin
  
  match "botsnack", method: :feed
  match "snackcount", method: :snackcount
  match "botsmack", method: :discipline
  match "smackcount", method: :smackcount
  match "speak", method: :speak
  
  def feed(m)
    m.reply "Thank You! :-)"
    @bot.database.incr("botsnacks")
  end
  
  
  def snackcount(m)
    m.reply "Total snacks eaten: #{@bot.database.get("botsnacks")}"
  end
  
  def discipline(m)
    m.reply "?!? D-:"
    @bot.database.incr("botsmacks")
  end
  
  def smackcount(m)
    m.reply "Total times smacked: #{@bot.database.get("botsmacks")}"
  end
  
  def speak(m)
    sources = %w{futurama prog_style subversion joel_on_software starwars calvin math hitchhiker}
    json = Quote.get('/api/v1/random', :query => { :max_lines => "5", :format => "json", :source => sources.join("+") })
    json['quote'].split("\n\t").each do |line|
      m.reply line
    end
  end
end
