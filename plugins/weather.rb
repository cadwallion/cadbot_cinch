require 'nokogiri'
require 'em-http-request'

class Weather < CadBot::Plugin
  
  WEATHER_PAR = "1079693758"
	WEATHER_API = "a6939d9b2b51255c"
	QUERY_PARAMS = {
			'cc' => '*',
			'link' => 'xoap',
			'prod' => 'xoap',
			'par' => WEATHER_PAR,
			'key' => WEATHER_API
	}
  
  match /weather report (.+)/, method: :report
  match /weather forecast (.+)/, method: :forecast
  match /weather map (.+)/, method: :map
  match /weather search (.+)/, method: :search
  
  def report(m, postal)
    EventMachine.run do
      http = EventMachine::HttpRequest.new("http://xoap.weather.com/weather/local/#{postal}").get :query => QUERY_PARAMS
      http.callback do
        weather = Nokogiri::XML(http.response).root.xpath("/weather")
        if weather.xpath("//cc")
          m.reply "Location: #{weather.xpath('//loc/dnam').inner_text} - Updated at: #{weather.xpath('//cc/lsup').text}"
          current = "Temp: #{weather.xpath('//cc/tmp').text}F/#{convert_to_c(weather.xpath('//cc/tmp').text)}C - "
					current << "Feels like: #{weather.xpath("//cc/flik").text}F/#{convert_to_c(weather.xpath("//cc/flik").text)}C - "
					current << "Wind: #{weather.xpath("//cc/wind/t").text} #{weather.xpath("//cc/wind/s").text} MPH - "
					current << "Conditions: #{weather.xpath("//cc/t").text} - "
					current << "Humidity: #{weather.xpath("//cc/hmid").text}%"
					m.reply current
        else
          m.reply "City code not found."
        end
      end
    end
  end
  
  def forecast(m, postal)
    EventMachine.run do
      http = EventMachine::HttpRequest.new("http://xoap.weather.com/weather/local/#{postal}").get :query => QUERY_PARAMS.merge('dayf' => '5')
      http.callback do
        weather = Nokogiri::XML(http.response).root.xpath("/weather")
        if weather.xpath('//dayf')
          m.reply "Location: #{weather.xpath('//loc/dnam').inner_text}"
          weather.xpath('//dayf/day').each do |day|
            forecast = "#{day['t']} #{day['dt']} - High: #{day.xpath('hi').text}F/#{convert_to_c(day.xpath('hi').text)}C"
            forecast << "# - Low: #{day.xpath('low').text}F/#{convert_to_c(day.xpath('low').text)}C"
            
            day.xpath('part').each do |part|
  						if part['p'] == "n"
  							forecast << " - Night: #{part.xpath('t').text}"
  						else
  							forecast << " - Day: #{part.xpath('t').text}"
  						end
  					end
  					m.reply forecast
          end
        else
          m.reply "City code not found."
        end
      end
    end
  end
  
  def search(m, postal)
    EventMachine.run do
      http = EventMachine::HttpRequest.new("http://xoap.weather.com/search/search").get :query => { 'where' => postal }
      http.callback do
        weather = Nokogiri::XML(http.response).root
        if weather.xpath('/search/loc')
          locations = []
          weather.xpath('/search/loc').each do |location|
            locations << "#{location.text} (#{location['id']})"
          end
          m.reply(locations.join(", "))
        else
          m.reply "City code not found."
        end
      end
      http.errback do
        m.reply "Error retrieving results."
      end
    end
  end
  
  def map(m, postal)
    m.reply "http://www.weather.com/weather/map/interactive/#{postal}"
  end
  
  def convert_to_c(value)
		if value =~ /^[\-0-9]*$/
			( value.to_i - 32 ) * 5 / 9
		else
			"N/A"
		end
	end
end