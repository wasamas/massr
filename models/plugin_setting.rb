module Massr
	class PluginSetting
		include ::Mongoid::Document
		store_in collection: 'massr.plugin_settings'
		
		field :plugin, type: String
		field :key,    type: String
		field :value,  type: String
		validates_presence_of :plugin, :key, :value

		def self.set(key, value)
			set = where(plugin: plugin_name, key: key).first
			if set
				set.update_attribute(:value, value)
			else
				set = self.create(plugin: plugin_name, key: key, value: value)
				set.save
			end
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

