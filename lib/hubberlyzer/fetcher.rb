module Hubberlyzer
	class Fetcher

		class ResponseError < StandardError
		end

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
		
		def githubber_links
			response_body = fetch_page
			parse_listing(response_body)
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
			    raise ResponseError, "Time out when requesting: #{url}"
			  elsif response.code != 200
			    raise ResponseError, "Response code #{response.code}, #{response.return_message} when requesting: #{url}"
			  else
			    # Received a non-successful http response.
			    raise ResponseError, "HTTP request failed. Response code #{response.code} when requesting: #{url}"
			  end
			end

			request.run

			request.response.body
		end

		def parse_listing(body)
			links = []
			selector = "li.hubbers-list-item > a"
			b = Nokogiri::HTML(body)
			hubbers = b.css(selector)
			hubbers.each do |hubber|
				link = hubber['href']
				if link
					links << (link[0] == '/' ? "https://github.com#{link}" : link)
				else
					puts "Error! Could not find href using #{selector}"
				end
			end
			links
		end
	end
end