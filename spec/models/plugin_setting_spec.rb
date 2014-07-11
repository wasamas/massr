# -*- coding: utf-8 -*-
require 'spec_helper'
require 'models/plugin_setting'

describe 'Massr::PluginSetting' do
	describe '#get' do
		before :all do
			Massr::PluginSetting.collection.remove
		end

		it('exist key') do
			Massr::PluginSetting.set('test', 'aaa')
			expect(Massr::PluginSetting.get('test')).to eq('aaa')
			Massr::PluginSetting.set('test', 'bbb')
			expect(Massr::PluginSetting.get('test')).to eq('bbb')
		end

		it('no exist key') do
			Massr::PluginSetting.set('test', 'aaa')
			expect(Massr::PluginSetting.get('hoge')).to be nil
		end
	end
end

