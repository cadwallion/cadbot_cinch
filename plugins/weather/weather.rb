require 'nokogiri'
require 'em-http-request'

class Weather
  include Cinch::Plugin
  
  WEATHER_PAR = "1079693758"
	WEATHER_API = "a6939d9b2b51255c"
	QUERY_PARAMS = {
			'cc' => '*',
			'link' => 'xoap',
			'prod' => 'xoap',
			'par' => WEATHER_PAR,
			'key' => WEATHER_API
	}

  match /^@weather$/, method: :report, :use_prefix => false
  match /^@weather report(.+)?/, method: :report, :use_prefix => false
  match /^@weather forecast(.+)?/, method: :forecast, :use_prefix => false
  match /^@weather search (.+)$/, method: :search, :use_prefix => false 
  match /^@weather map(.+)?/, method: :map, :use_prefix => false
  match /^@weather convert (.+)$/, method: :convert, :use_prefix => false
  match /^@weather save (.+)$/, method: :save, :use_prefix => false
  match /^@weather help$/, method: :help, :use_prefix => false
  
  def report(m, param = nil)
    postal = get_user_postal(m.user.nick, param)
    return if postal.nil?

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
  
  def forecast(m, param)
    postal = get_user_postal(m.user.nick, param)
    return if postal.nil?
    
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
      http.errback do
        m.reply "Error accessing weather information, please try again."
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
    postal = get_user_postal(m.user.nick, postal)
    return if postal.nil?
    m.reply "http://www.weather.com/weather/map/interactive/#{postal}"
  end
  
  def convert(m, temp)
    if temp =~ /^([\-0-9]*)([Ff]|[Cc])$/
      value = $1
      if $2 =~ /F|f/
        to = "C"
        from = "F"
        conversion = convert_to_c(value)
      else
        to = "F"
        from = "C"
        conversion = convert_to_f(value)
      end
      
      if conversion == "N/A"
        m.reply "Conversion returned null, please try again."
      else
        m.reply("#{temp} converts to #{conversion}#{to}")
      end
    else
      
      m.reply "Cannot convert that temperature, please try again."
    end
  end
  
  def save(m, postal)
    unless postal == ''
      @bot.database.set("user:#{m.user.nick}:postal", postal)
      m.reply "Location saved."
    end
  end
  
  def get_user_postal(user, param)
    if param == '' || param.nil?
      postal = @bot.database.get("user:#{user}:postal")
      if postal.nil?
        m.reply "Postal code not provided nor on file."
        return nil
      else
        return postal
      end
    else
      return param.strip
    end
  end
  
  def convert_to_c(value)
		if value =~ /^[\-0-9]*$/
			( value.to_i - 32 ) * 5 / 9
		else
			"N/A"
		end
	end
	
	def convert_to_f(value)
	  if value =~ /^[-0-9]*$/
	    ((value.to_i * 9) / 5 ) + 32
    else
      "N/A"
    end
	end
end
