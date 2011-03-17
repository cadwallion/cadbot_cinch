class AdminPlugin < CadBot::Plugin

  hook :pre, method: :authorize
  def admins
    @admins ||= ["Cadwallion", "CadPhone", "Cadmind"]
  end
  
  def authorize(m)
    
  end
  
  def check_user(user)
    admins.include?(user.nick)
  end
end