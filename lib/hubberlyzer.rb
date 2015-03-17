require "typhoeus"
require "nokogiri"

require 'hubberlyzer/fetcher'
require 'hubberlyzer/profiler'
require "hubberlyzer/version"

module Hubberlyzer
  class ResponseError < StandardError
	end
end
