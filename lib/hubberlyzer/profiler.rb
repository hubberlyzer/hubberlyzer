module Hubberlyzer
  # Profiler get githubber's profile information and repositories stats from their profile page.
  #
  # Profile:
  #   full name
  #   username
  #   location
  #   email
  #   external link
  #   datetime of join
  # 
  # Repository Stats:
  #   total count group by language
  #   total stars group by language
  class Profiler

    # Convenient method that calls #githubber_links and #fetch_profile_pages together
    def get_githubbers(url, max_page=1, options={})
      links = githubber_links(url, max_page, options)
      fetch_profile_pages(links)
    end

    # Fetch people's profile url given the url of this organization's people page
    # Returns array of the memeber's profile url
    # url: the link to organization's people page (e.g. https://github.com/orgs/github/people)
    # options: optional parameters that passe to http request client (Typhoeus)
    def githubber_links(url, max_page=1, options={})
      links = []
      if max_page && max_page > 1

        # add pagination param
        urls = (1..max_page).map { |i| "#{url}?page=#{i}" }
        responses = fetch(urls, options)
        responses.each do |response|
          links += get_profile_url(Nokogiri::HTML(response))
        end
      else
        response = fetch(url)
        links = get_profile_url(Nokogiri::HTML(response))
      end
      links
    end

    # Fetch a user's profile page
    def fetch_profile_page(url)
      url = "#{url}?tab=repositories"
      response = fetch(url)
      hubber = parse_profile_page(response)
      hubber
    end

    # Fetch an array of user's profile urls concurrently
    def fetch_profile_pages(urls)
      urls = urls.map { |l| "#{l}?tab=repositories" }
      responses = fetch(urls)
      hubbers = responses.map do |response|
        parse_profile_page(response)
      end
      hubbers
    end

    def parse_profile_page(body)
      html = Nokogiri::HTML(body)
      hubber = Hubber.new
      hubber.profile = parse_profile(html)
      hubber.stats = parse_repo_stats(html)
      hubber
    end
    
    # Get the basic information of this user
    def parse_profile(html)
      profile = {}
      profile["username"]  = html.at_css('.vcard-username').text # Must have username, will raise error is not found
      profile["fullname"]  = (node = html.at_css('.vcard-fullname')).nil? ? "" : node.text
      profile["location"]  = (node = html.at_xpath("//*[@class='vcard-details']/li[2]")).nil? ? "" : node.text
      profile["email"]     = (node = html.at_xpath("//*[@class='vcard-details']/li[3]")).nil? ? "" : node.text
      profile["link"]      = (node = html.at_xpath("//*[@class='vcard-details']/li[4]")).nil? ? "" : node.text
      profile["join_date"] = (node = html.xpath("//*[@class='join-date']/@datetime").first).nil? ? "" : node.value
      profile
    end

    # Parse and calculate the total number of repos and stars 
    # grouped them by each language. 
    # e.g. {"Ruby" => {"count" => 31, "star" => 100}, ...}
    def parse_repo_stats(html)
      lang_count = {}

      html.css("li.repo-list-item").each do |repo|
        stats = repo.at_css(".repo-list-stats").text.split

        next if stats.length != 3 #assume the language part is missing

        lang = stats[0].strip
        star = stats[1].strip.to_i # this may cause problem, since Ruby tries to convert any string to number, and will return 0 if it's not a number

        # exclude forked repo with 1 star.
        if star < 2 && is_forked(repo)
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
    def get_profile_url(html)
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