require 'googleajax'

class Google < CadBot::Plugin
  
  match /google (.+)/, method: :search
  
  
  def search(m, query)
    GoogleAjax.referrer = 'cadwallion.com'
    
    result = GoogleAjax::Search.web(query)[:results][0]
    m.reply "Result: #{result[:title]} - #{result[:url]}"
  end
end