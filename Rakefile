require 'rubygems'
require 'rake'

begin
	require 'rspec/core/rake_task'
	desc 'Run the code in specs'
	RSpec::Core::RakeTask.new(:spec) do |t|
		t.pattern = "spec/**/*_spec.rb"
	end
	task :default => [:spec]
rescue LoadError => e
end

require './massr'
require 'sprockets'
require 'fileutils'

namespace :db do
	desc 'Create MongoDB indexes'
	task :create_indexes do
		require './models/init'
		Mongoid.models.each do |model|
			puts "Creating indexes for #{model.name}..."
			model.create_indexes
		end
		puts "Indexes created successfully!"
	end
end

namespace :assets do
	desc 'Precompile assets'
	task :precompile do
		sprockets = Massr::App.sprockets
		manifest = Sprockets::Manifest.new(sprockets, File.join(Massr::App.public_folder, 'assets'))

		# Clean old assets
		FileUtils.rm_rf(File.join(Massr::App.public_folder, 'assets'))

		# Compile assets
		manifest.compile(['application.js', 'application.css'])
	end

	desc 'Clean compiled assets'
	task :clean do
		FileUtils.rm_rf(File.join(Massr::App.public_folder, 'assets'))
	end
end

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
# vim: ts=3
