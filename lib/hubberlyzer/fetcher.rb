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
			@max_concurrency = options[:max_concurrency] || 5
		end

		def fetch_page
			request = init_request(init_url)
			request.run
			request.response.body
		end

		def fetch_pages
			urls = init_url
			
			hydra = Typhoeus::Hydra.new(max_concurrency: @max_concurrency)

			requests = urls.map do |url|
				request = init_request(url)
				hydra.queue(request)
				request
			end

			hydra.run

			responses = requests.map do |request|
			  request.response.body
			end

			responses
		end

		private

		# Create an request instance with callbacks
		def init_request(url)
			request = Typhoeus::Request.new(
				url,
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

			request
		end
	end
end