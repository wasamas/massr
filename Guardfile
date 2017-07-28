guard :rspec, cmd: "bundle exec rspec" do
  require "guard/rspec/dsl"
  dsl = Guard::RSpec::Dsl.new(self)

  # Feel free to open issues for suggestions and improvements

  # RSpec files
  rspec = dsl.rspec
  watch(rspec.spec_helper) { rspec.spec_dir }
  watch(rspec.spec_support) { rspec.spec_dir }
  watch(rspec.spec_files)

  # Ruby files
  ruby = dsl.ruby
  watch('massr.rb') { rspec.spec_dir }
  watch(%r[^models/(?<file>.+)\.rb$]){|m| "#{rspec.spec_dir}/models/#{m[:file]}_spec.rb"}
  dsl.watch_spec_files_for(ruby.lib_files)

end
