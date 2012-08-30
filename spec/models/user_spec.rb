# -*- coding: utf-8 -*-
require 'spec_helper'
require 'massr/models/user'

describe 'Massr::User' do
	before do
		Massr::User.collection.remove
	end

	after do
	end
end
