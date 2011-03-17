require './lib/cad_bot'
Process.daemon()
CadBot::Manager.new.run