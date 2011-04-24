class CadBot
  class Database
    class << self
      def load(config)
        @connection ||= Redis.new
      end
      
      def connection
        raise "Cannot access database, configuration not loaded." if @connection.nil?
        @connection
      end
    end
  end
end