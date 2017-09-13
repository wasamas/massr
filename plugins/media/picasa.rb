# media/picasa.rb : DEPRECATED plugin, picasaweb service was dead
#
# Copyright (C) 2012 by The wasam@s production
# https://github.com/tdtds/massr
#
# Distributed under GPL
#
require 'rmagick'

#
# Massr Picasa plugin
#
module Massr
	module Plugin::Media
		class Picasa
			def initialize(label, opts)
				$stderr.puts 'picasa plugin is DEPRECATED. picasaweb service is dead.'
			end

			def resize_file(path, size = 0, square = false)
				size = DEFAULT_UPLOAD_PHOTO_SIZE if size == 0
				photo = Magick::ImageList.new(path).first
				if photo.columns > size || photo.rows > size
					photo.resize_to_fit!(size, size)
					photo.write(path)
				end
				if square
					img = Magick::Image.new(size, size)
					img.background_color = '#ffffff'
					img.composite!(photo, Magick::CenterGravity, Magick::OverCompositeOp)
					img.format = photo.format
					img.write(path)
					img.destroy!
				end
				photo.destroy!
			end

			def upload_file(path, content_type, display_size = nil); end
		end
	end
end

