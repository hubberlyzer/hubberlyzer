module Hubberlyzer
	class Fetcher

		UA = [
			"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/36.0.1985.125 Safari/537.36",
			"Mozilla/5.0 (Windows NT 6.2; WOW64; rv:21.0) Gecko/20100101 Firefox/21.0",
			"Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 6.0)",
			"Mozilla/5.0 (Windows NT 6.1; WOW64; rv:29.0) Gecko/20120101 Firefox/29.0"
		]

		attr_accessor :init_url, :user_agent

		def initialize(url, options={})
			@init_url = url
			@user_agent = options[:user_agent] || UA.sample
		end

		def fetch_page
			request = Typhoeus::Request.new(
				init_url,
				method: :get,
				headers: {'User-Agent' => user_agent}, 
				followlocation: true
				# proxy: ...,
				# proxyuserpwd: ...
			)

			request.on_complete do |response|
				if response.success?
					# do nothing here
			  elsif response.timed_out?
			    raise Hubberlyzer::ResponseError, "Time out when requesting: #{url}"
			  elsif response.code != 200
			    raise Hubberlyzer::ResponseError, "Response code #{response.code}, #{response.return_message} when requesting: #{url}"
			  else
			    # Received a non-successful http response.
			    raise Hubberlyzer::ResponseError, "HTTP request failed. Response code #{response.code} when requesting: #{url}"
			  end
			end

			request.run

			request.response.body
		end
	end
end