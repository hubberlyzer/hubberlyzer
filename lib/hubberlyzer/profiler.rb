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

		def fetch_profile_page(url)
			fetcher = Hubberlyzer::Fetcher.new(url)
			response_body = fetcher.fetch_page

			# html = Nokogiri::HTML(body)
			# parse_profile(html)
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
				star = stats[1].strip
				if lang_count.has_key?(lang)
					lang_count[lang]["count"] += 1
					lang_count[lang]["star"] += star.to_i # this may cause problem, since Ruby tries to convert any string to number, and will return 0 if it's not a number
				else
					lang_count[lang] = {}
					lang_count[lang]["count"] = 1
					lang_count[lang]["star"] = star.to_i
				end
			end
			lang_count
		end
	end
end