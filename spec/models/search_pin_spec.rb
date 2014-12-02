# -*- coding: utf-8 -*-
require 'spec_helper'
require 'models/search_pin'

describe 'Massr::SearchPin', :type => :model do
	describe '.create_by_word' do
		before :all do
			Massr::SearchPin.collection.remove
			@pin = Massr::SearchPin.create_by_word('aaa')
		end
		subject{ @pin }

		describe '#word' do
		  subject { super().word }
		  it {is_expected.to eq('aaa')}
		end

		describe '#label' do
		  subject { super().label }
		  it {is_expected.to eq('aaa')}
		end
	end

	describe '#label=' do
		before :all do
			Massr::SearchPin.collection.remove
			@pin = Massr::SearchPin.create_by_word('aaa')
			@pin.label = 'bbb'
		end
		subject{ @pin }

		describe '#word' do
		  subject { super().word }
		  it {is_expected.to eq('aaa')}
		end

		describe '#label' do
		  subject { super().label }
		  it {is_expected.to eq('bbb')}
		end
	end
end
