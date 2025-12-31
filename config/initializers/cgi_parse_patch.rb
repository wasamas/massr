# Monkey patch for Ruby 4.0 compatibility
# CGI.parse was removed in Ruby 4.0, but oauth gem still uses it
require 'uri'

class CGI
  def self.parse(query_string)
    params = Hash.new { |hash, key| hash[key] = [] }
    return params if query_string.nil? || query_string.empty?

    URI.decode_www_form(query_string).each do |key, value|
      params[key] << value
    end

    params
  end
end
