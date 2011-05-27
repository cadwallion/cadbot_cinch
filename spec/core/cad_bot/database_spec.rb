require 'spec_helper'
describe CadBot::Database do
  before(:each) do
    CadBot::Database.disconnect
  end
  describe "#load" do
    it "sets the @connection attr" do
      CadBot::Database.load(:host => "127.0.0.1")
      CadBot::Database.connection.should_not be_nil
    end
    
    it "caches the connection" do
      CadBot::Database.load(:host => "127.0.0.1")
      connection = CadBot::Database.connection
      CadBot::Database.load(:host => "127.0.0.1")
      CadBot::Database.connection.should be(connection)
    end
  end
  
  describe "#connection" do
    it "should raise an error if connection has not been established" do
      expect { CadBot::Database.connection }.to raise_error(RuntimeError, 
        "Cannot access database, configuration not loaded.")
    end
  end
  
  describe "#disconnect" do
    it "should kill the connection to the database" do
      CadBot::Database.load(:host => "127.0.0.1")
      CadBot::Database.disconnect
      expect { CadBot::Database.connection }.to raise_error(RuntimeError, 
        "Cannot access database, configuration not loaded.")
    end
  end
end