# -*- coding: utf-8; -*-
require 'mongo_mapper'

module Massr
	class SearchPin
		include MongoMapper::Document

		key :word,  :type => String, :required => true, :unique => true
		key :label, :type => String, :required => true

		def self.create_by_word(word, label = nil)
			pin = SearchPin.new(word: word, label: label ? label : word)
			pin.save!
			return pin
		end

		def label=(label)
			self[:label] = label
			save!
			self
		end
	end
end

