module Massr
	class SearchPin
		include ::Mongoid::Document
		store_in collection: 'massr.search_pins'

		field :word,  type: String
		field :label, type: String
		validates_presence_of :word, :label
		validates_uniqueness_of :word

		def self.create_by_word(word, label = nil)
			pin = SearchPin.create(word: word, label: label ? label : word)
			pin.save
			return pin
		end

		def label=(label)
			self[:label] = label
			save
			self
		end
	end
end

