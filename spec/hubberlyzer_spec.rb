require 'spec_helper'

describe Hubberlyzer do
  it 'has a version number' do
    expect(Hubberlyzer::VERSION).not_to be nil
  end

  it 'fetches staff listings' do
    links = Hubberlyzer::Fetcher.new("https://github.com/about/team").githubber_links
    expect(links).not_to eq(0)
  end

  it 'fetches user profile page' do
  	p = Hubberlyzer::Profiler.new
  	body = p.fetch_profile_page("https://github.com/defunkt")
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

  it 'fetches user repositories and calculates the count' do
  	p = Hubberlyzer::Profiler.new
  	body = p.fetch_profile_page("https://github.com/steventen?tab=repositories")
  	repo_count = p.parse_repo(Nokogiri::HTML(body))
  	expect(repo_count).to include("Ruby")
	end
end
