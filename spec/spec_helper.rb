# -*- coding: utf-8 -*-
$:.unshift File.expand_path(File.join(File.dirname(__FILE__), '../lib')).untaint
Bundler.require :test if defined?(Bundler)

RSpec.configure do |config|
	require 'mongo_mapper'
	MongoMapper.connection = Mongo::Connection.new('localhost', 27017)
	MongoMapper.database = 'massr_test'
	config.before(:each) do
		MongoMapper.database.collections.each {|collection| collection.remove}
	end
end
