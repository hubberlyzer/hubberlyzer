require 'spec_helper'

describe "Profiler" do
  it "has a version number" do
    expect(Hubberlyzer::VERSION).not_to be nil
  end

  it "fetches all people's profile urls under the organization" do
  	p = Hubberlyzer::Profiler.new
  	links = p.githubber_links("https://github.com/orgs/github/people", 4)
    expect(links.length).to eq(4*30)
  end

  it "fetches user profile information correctly" do
  	p = Hubberlyzer::Profiler.new
  	body = p.send(:fetch, "https://github.com/defunkt?tab=repositories")
  	profile = p.parse_profile(Nokogiri::HTML(body))
  	expect(profile).to include(
  		"fullname" => "Chris Wanstrath",
  		"username" => "defunkt",
  		"location" => "San Francisco",
  		"email" => "chris@github.com",
  		"link" => "http://chriswanstrath.com/",
  		"join_date" => "2007-10-20T05:24:19Z"
  	)
  end

  it "fetches user repositories stats correctly" do
  	p = Hubberlyzer::Profiler.new
  	body = p.send(:fetch, "https://github.com/steventen?tab=repositories")
  	repo_count = p.parse_repo(Nokogiri::HTML(body))
  	expect(repo_count).to include("Ruby")
	end

	it "fetches all the information from profile page" do
		p = Hubberlyzer::Profiler.new
		info = p.fetch_profile_page("https://github.com/steventen?tab=repositories")
		expect(info).to include("profile", "stats")
	end

	it "fetches multiple profile pages concurrently" do
  	links = [
  		"https://github.com/defunkt?tab=repositories",
  		"https://github.com/pjhyett?tab=repositories",
  		"https://github.com/schacon?tab=repositories",
  		"https://github.com/tekkub?tab=repositories",
  		"https://github.com/rtomayko?tab=repositories",
  		"https://github.com/technoweenie?tab=repositories"
  	]

  	p = Hubberlyzer::Profiler.new
		info = p.fetch_profile_pages(links)
		puts info.inspect
		expect(info.length).to eq(links.length)
	end
end
