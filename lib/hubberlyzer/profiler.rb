# Get githubber's profile information from profile page
# Default only fetch on page 1
# Profile:
# 	Full Name
# 	Location
# 	Email
#   Social Account (Twitter Only)
#   Date Of Join
#   Number of Follower
# Repository Summary
#   language usage count
module Hubberlyzer
	class Profiler
		# url: the link to organization's people page (e.g. https://github.com/orgs/github/people)
		# returns all the memeber's profile page url
		# Notice that currently it will not try to detect the max page.
		# It will only fetch the first page if max_page is nil.
		def githubber_links(url, max_page=nil)
			links = []
			if max_page && max_page > 1
				# add pagination param
				urls = (1..max_page).map { |i| "#{url}?page=#{i}" }
				responses = fetch(urls, max_concurrency: 2)
				responses.each do |response_body|
					links += parse_hubbers(Nokogiri::HTML(response_body))
				end
			else
				response_body = fetch(url)
				links = parse_hubbers(Nokogiri::HTML(response_body))
			end
			links
		end

		# Fetch a user's profile page
		def fetch_profile_page(url)
			url = "#{url}?tab=repositories"
			response_body = fetch(url)

			parse_page(response_body)
		end

		# Fetch array of urls concurrently
		def fetch_profile_pages(urls)
			urls = urls.map { |l| "#{l}?tab=repositories" }
			responses = fetch(urls)
			responses.map do |response_body|
				parse_page(response_body)
			end
		end

		def parse_page(body)
			html = Nokogiri::HTML(body)
			profile = parse_profile(html)
			lang_count = parse_repo(html)

			{"profile" => profile, "stats" => lang_count}
		end
		
		def parse_profile(html)
			profile = {}
			profile["fullname"]  = html.at_css('.vcard-fullname').text
			profile["username"]  = html.at_css('.vcard-username').text
			profile["location"]  = html.at_xpath("//*[@class='vcard-details']/li[2]").text
			profile["email"]     = html.at_xpath("//*[@class='vcard-details']/li[3]").text
			profile["link"]      = html.at_xpath("//*[@class='vcard-details']/li[4]").text
			profile["join_date"] = html.xpath("//*[@class='join-date']/@datetime").first.value
			profile
		end

		def parse_repo(html)
			lang_count = {} #calculate the total number of repos and stars written in each language. e.g. {"Ruby" => {"count" => 31, "star" => 100}}

			html.css("li.repo-list-item").each do |repo|
				stats = repo.at_css(".repo-list-stats").text.split

				next if stats.length != 3 #assume the language part is missing

				lang = stats[0].strip
				star = stats[1].strip.to_i # this may cause problem, since Ruby tries to convert any string to number, and will return 0 if it's not a number

				# exclude forked repo with 0 star.
				if star == 0 && is_forked(repo)
					next
				end

				if lang_count.has_key?(lang)
					lang_count[lang]["count"] += 1
					lang_count[lang]["star"] += star
				else
					lang_count[lang] = {}
					lang_count[lang]["count"] = 1
					lang_count[lang]["star"] = star
				end
			end
			lang_count
		end

		# Get githubbers' profile url
		def parse_hubbers(html)
			links = []
			selector = "li.member-list-item a.member-link"

			hubbers = html.css(selector)
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

		private

		# If the url is String, then use normal request
		# If the url is Array, then use concurrent model.
		def fetch(url, options={})
			fetcher = Hubberlyzer::Fetcher.new(url, options)
			if url.is_a? Array
				response_body = fetcher.fetch_pages
			else
				response_body = fetcher.fetch_page
			end
		end

		def is_forked(node)
			node["class"].include?("fork")
		end
	end
end