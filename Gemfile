source "http://rubygems.org"

gem "cinch", :git => "git://github.com/cadwallion/cinch.git", :branch => "invest"
gem "redis", "~>2.2.0"
gem "rspec", "~>2.5.0", :group => :test

# Plugin-specific gem deps
Dir["plugins/**/Gemfile"].each do |gemfile|
  self.send(:eval, File.open(gemfile, 'r').read)
end