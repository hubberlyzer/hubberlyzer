module Hubberlyzer
  class Analyzer
    
    # The data collection is coming from Profiler#fetch_profile_pages method
    # Check spec/fixtures/sample.rb to see how it looks like
    def initialize(data)
      @data = data
    end

    # Total count and star of repositories group by language of all member
    # Return a Hash e.g. {"Ruby"=>{"count"=>10, "star"=>10}, "JavaScript"=>{"count"=>10, "star"=>10}, ...}
    def sum_by_language
      sum = {}
      @data.each do |p|
        sum = sum.merge(p["stats"]) do |k, v1, v2|
          {"count" => (v1["count"] + v2["count"]), "star" => (v1["star"] + v2["star"])}
        end
      end
      sum
    end

    # Total count and star of repositories group by language of all member
    # Only top x number of language is kept with desc order
    # Return an Array e.g. [["C", 10], ["JavaScript", 7], ["Ruby", 6]]
    def top_language(base="count", top=30)
      sum = {}
      @data.each do |p|
        p["stats"].each do |k, v|
          if sum.has_key?(k)
            sum[k] += v[base]
          else
            sum[k] = v[base]
          end
        end
      end
      sum.sort_by{ |k, v| -1*v }[0...top]
    end

    # Return a list of people, who contribute to this lang
    # The contribution can either based on 'count', or 'star'
    # The list is ordered by total of 'count' or 'star' they have
    # Return e.g. [{"profile"=>{"username"=>"bbb", ...}, "star"=>10}, {"profile"=>{"username"=>"aaa", ...}, "star"=>0}]
    def member_contrib(lang, base="star", top=10)
      member = []
      @data.each do |p|
        next unless p["stats"].has_key?(lang)

        counter = p["stats"][lang][base]
        member << { "profile" => p["profile"], base => counter }
      end

      if !member.empty? && member.length > 1
        # sort the results
        member.sort! { |a, b|  b[base] <=> a[base] }
      end
      member[0...top]
    end
  end
end