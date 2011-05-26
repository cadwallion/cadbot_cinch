require 'json'
require 'em-http-request'
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
    EventMachine.run do
      http = EventMachine::HttpRequest.new("http://www.iheartquotes.com/api/v1/random").get(:max_lines => "1", :format= "json")
      http.callback do
        json = JSON.parse(http.response)
        m.reply "#{json['quote']}"
      end
    end
  end
end
