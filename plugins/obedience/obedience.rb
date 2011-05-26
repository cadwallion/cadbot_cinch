class Obedience
  include Cinch::Plugin
  
  match "botsnack", method: :feed
  match "snackcount", method: :snackcount
  match "botsmack", method: :discipline
  match "smackcount", method: :smackcount
  
  def feed
    m.reply "Thank You! :-)"
    @bot.database.incr("botsnacks")
  end
  
  
  def snackcount
    m.reply "Total snacks eaten: #{@bot.database.get("botsnacks")}"
  end
  
  def discipline
    m.reply "?!? D-:"
    @bot.database.incr("botsmacks")
  end
  
  def smackcount
    m.reply "Total times smacked: #{@bot.database.get("botsmacks")}"
  end
end