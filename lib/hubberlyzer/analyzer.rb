module Hubberlyzer
	class Analyzer
		
		# The data collection is coming from Profiler#fetch_profile_pages method
		# Check spec/fixtures/sample.rb to see how it looks like
		def initialize(data)
			@data = data
		end

		# Total count and star of repositories group by language of all member
		def sum_by_language
			sum = {}
			@data.each do |p|
				sum = sum.merge(p["stats"]) do |k, v1, v2|
					{"count" => (v1["count"] + v2["count"]), "star" => (v1["star"] + v2["star"])}
				end
			end
			sum
		end

		# Return a list of people, who contribute to this lang
		# The contribution can either based on 'count', or 'star'
		# The list is ordered by total of 'count' or 'star' they have
		def member_contrib(lang, base="star")
			member = []
			@data.each do |p|
				next unless p["stats"].has_key?(lang)

				username = p["profile"]["username"]
				counter = p["stats"][lang][base]
				member << { "username" => username, base => counter }
			end

			if !member.empty? && member.length > 1
				# sort the results
				member.sort! { |a, b|  b[base] <=> a[base] }
			end
			member
		end
	end
end