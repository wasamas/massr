require 'rubygems'
require 'rake'
require 'rspec/core/rake_task'

task :default => [:spec]

desc 'Run the code in specs'
RSpec::Core::RakeTask.new(:spec) do |t|
	t.pattern = "spec/**/*_spec.rb"
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3
