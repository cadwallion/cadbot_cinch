source "http://rubygems.org"

gem "cinch", "~>1.1.2"
gem "redis", "~>2.2.0"

# Plugin-specific gem deps
Dir["plugins/**/Gemfile"].each do |gemfile|
  self.send(:eval, File.open(gemfile, 'r').read)
end