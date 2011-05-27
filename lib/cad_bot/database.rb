class CadBot
  class Database
    class << self
      attr_accessor :connection, :test
      def load(config)
        @connection ||= Redis.new(config.merge(:thread_safe => true))
      end
      
      def connection
        if @test
          @connection = nil
        else
          raise "Cannot access database, configuration not loaded." if @connection.nil?
          @connection
        end
      end
      
      def disconnect
        @connection = nil
      end
    end
  end
end
