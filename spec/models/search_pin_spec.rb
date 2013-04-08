# -*- coding: utf-8 -*-
require 'spec_helper'
require 'models/search_pin'

describe 'Massr::SearchPin' do
	describe '.create_by_word' do
		before :all do
			Massr::SearchPin.collection.remove
			@pin = Massr::SearchPin.create_by_word('aaa')
		end
		subject{ @pin }
		its(:word){should eq('aaa')}
		its(:label){should eq('aaa')}
	end

	describe '#label=' do
		before :all do
			Massr::SearchPin.collection.remove
			@pin = Massr::SearchPin.create_by_word('aaa')
			@pin.label = 'bbb'
		end
		subject{ @pin }
		its(:word){should eq('aaa')}
		its(:label){should eq('bbb')}
	end
end
