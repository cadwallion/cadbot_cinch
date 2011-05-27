require 'rspec/core/rake_task'

namespace :test do
  desc "Run specs"
  RSpec::Core::RakeTask.new(:core) do |t|
    t.pattern = "./spec/core/**/*_spec.rb" # don't need this, it's default.
    # Put spec opts in a file named .rspec in root
  end
  
  desc "Run plugin specs"
  RSpec::Core::RakeTask.new(:plugins) do |t|
    t.pattern = "./spec/plugins/**/*_spec.rb"
  end

  desc "Generate code coverage"
  RSpec::Core::RakeTask.new(:coverage) do |t|
    t.pattern = "./spec/**/*_spec.rb"
    t.rcov = true
    t.rcov_opts = ['--exclude', 'spec']
  end
end