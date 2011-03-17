class Channel < AdminPlugin
  match /join (.+)/, method: :join
  match /part (.+)/, method: :part
  
  def join(m)
    
  end
  
  def part(m)
    
  end
end