class CadBot
  class Database
    class << self
      attr_accessor :connection
      def load(config)
        @connection ||= Redis.new(config.merge(:thread_safe => true))
      end
      
      def connection
        raise "Cannot access database, configuration not loaded." if @connection.nil?
        @connection
      end
      
      def disconnect
        @connection = nil
      end
    end
  end
end