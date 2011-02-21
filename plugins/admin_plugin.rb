class AdminPlugin
  include Cinch::Plugin
  
  hook :pre, method: :authorize
  def admins
    @admins ||= ["Cadwallion", "CadPhone", "Cadmind"]
  end
  
  def authorize(m)
    if check_user(m.user)
      
  end
  
  def check_user(user)
    admins.include?(user.nick)
  end
end