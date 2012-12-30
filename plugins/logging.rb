require 'singleton'
require 'logger'

#
# Massr Logging plugin
#

module Massr
	module Plugin
		class Logging
			include Singleton

			FATAL = Logger::FATAL
			ERROR = Logger::ERROR
			WARN  = Logger::WARN
			INFO  = Logger::INFO
			DEBUG = Logger::DEBUG

			def info(msg)
				@logger.info(msg)
			end

			def fatal(msg)
				@logger.fatal(msg)
			end

			def error(msg)
				@logger.error(msg)
			end

			def warn(msg)
				@logger.warn(msg)
			end

			def debug(msg)
				@logger.debug(msg)
			end

			def level(lv)
				@logger.level = lv
			end

			def initialize
				@logger ||= Logger.new(STDOUT)
			end
		end
	end
end
