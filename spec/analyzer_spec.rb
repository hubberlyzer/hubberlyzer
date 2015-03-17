require 'spec_helper'

describe "Analyzer" do
  let(:test_data){ [
    { 
      "profile" => {
        "username"=>"aaa"
      }, 
      "stats" => { 
        "Ruby" => {"count"=>5, "star"=>0 },
        "JavaScript" => { "count"=> 1, "star"=>10 }
      }
    }, 
    {
      "profile" => {
        "username"=>"bbb"
      }, 
      "stats" => { 
        "Ruby" => {"count"=>5, "star"=>10 },
        "C" => { "count"=> 10, "star"=>10 },
        "JavaScript" => { "count"=> 9, "star"=>0 }
      }
    }
  ]}

  it "calculate sum by language" do

  	p = Hubberlyzer::Analyzer.new(test_data)
    sum = p.sum_by_language

    expect(sum["C"]["count"]).to eq(10)
    expect(sum["Ruby"]["count"]).to eq(10)
    expect(sum["JavaScript"]["count"]).to eq(10)

    expect(sum["C"]["star"]).to eq(10)
    expect(sum["Ruby"]["star"]).to eq(10)
    expect(sum["JavaScript"]["star"]).to eq(10)
  end

  it "calculate member's contribution to a language" do
    p = Hubberlyzer::Analyzer.new(test_data)
    sum = p.member_contrib("Ruby", "star")

    expect(sum.length).to eq(2)
    expect(sum[0]["username"]).to eq("bbb")
    expect(sum[1]["username"]).to eq("aaa")

    expect(sum[0]["star"]).to eq(10)
    expect(sum[1]["star"]).to eq(0)
  end
end