# -*- coding: utf-8; -*-

module Massr
	class PluginSetting
		include MongoMapper::Document
		
		key :plugin, :type => String,   :required => true
		key :key,    :type => String,   :required => true
		key :value,  :type => String,   :required => true
		timestamps!

		def self.set(key, value)
			set = where(pluin: plugin_name, key: key).first || self.new(plugin: plugin_name, key: key)
			set[:value] = value
			set.save!
		end

		def self.get(key)
			set = where(plugin: plugin_name, key: key).first
			set ? set[:value] : nil
		end

	private
		def self.plugin_name
			path = caller[1].split(/:/).first
			return path.scan(%r|plugins/(.*)\.rb|).flatten.first || path
		end
	end
end

