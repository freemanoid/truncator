require 'spec_helper'
require 'truncator'

describe Truncator::UrlParser do

  describe ".shorten_url" do

    context "when no truncation length is specified, the URL is too long, has sublevels, but no query params" do
      let(:shortened) { Truncator::UrlParser.shorten_url "http://www.foo.com/this/is/a/b/c/d/e/f/string.html" }

      it "should default to truncate at 42 characters" do
        # shortened.should == "www.foo.com/this/is/a/.../e/f/string.html"
        shortened.length.should <= 42
      end
    end

    context 'when URL has a large last folder level' do
      let(:shortened) { Truncator::UrlParser.shorten_url "http://m.whitehouse.gov/blog/2013/08/23/check-out-secretary-education-arne-duncans-google-hangout-sal-khan?utm_source=email&utm_medium=email&utm_content=email232-graphic2&utm_campaign=education" }

      it "should should default to truncate at 42 characters" do
        shortened.should == "m.whitehouse.gov/blog/2013/08/23/check-..."
      end
    end

    context "when URL is too long, has sublevels, but no query params" do
      it "should ellipse the directories and just show the file" do
        Truncator::UrlParser.shorten_url("http://www.foo.com/this/is/a/really/long/url/that/has/no/query/string.html", 30).should == "www.foo.com/.../string.html"
      end

      it "should replace path segments with ellipses to shorten the path as much as necessary" do
        url_prefix = "http://www.foo.com/this/goes/on/"
        url_middle = ""
        url_suffix = "with/XXX.html"
        0.upto(20) do |n|
          url = url_prefix + url_middle + url_suffix
          url_middle += "and/on/"
          shorter_url = Truncator::UrlParser.shorten_url(url, 30)
          #TODO: rewrite this
          shorter_url.should == if url[7..-1].length <= 30
                                  url[7..-1]
                                else
                                  "www.foo.com/.../with/XXX.html"
                                end
        end
      end

      it "should replace path segments with ellipses to shorten the path as much as necessary (different path pattern)" do
        url_prefix = "http://www.foo.com/on/"
        url_middle = ""
        url_suffix = "X.html"
        0.upto(20) do |n|
          url = url_prefix + url_middle + url_suffix
          url_middle += "nd/on/"
          shorter_url = Truncator::UrlParser.shorten_url(url, 30)
          #TODO: rewrite this
          shorter_url.should == if url[7..-1].length <= 30
                                  url[7..-1]
                                else
                                  "www.foo.com/.../nd/on/X.html"
                                end
        end
      end

      # it "should replace path segments with ellipses to shorten the path as much as necessary for various lengths", focus: true do
      #   url = "http://www.foo.com/this/goes/on/and/on/and/on/with/XXX.html"
      #   Truncator::UrlParser.shorten_url(url, 24).should == "www.foo.com/.../XXX.html"
      #   32.upto(33) { |n| Truncator::UrlParser.shorten_url(url, n).should == "www.foo.com/.../on/with/XXX.html" }
      #   35.upto(39) { |n| Truncator::UrlParser.shorten_url(url, n).should == "www.foo.com/this/.../with/XXX.html" }
      #   40.upto(42) { |n| Truncator::UrlParser.shorten_url(url, n).should == "www.foo.com/this/goes/.../with/XXX.html" }
      #   43.upto(45) { |n| Truncator::UrlParser.shorten_url(url, n).should == "www.foo.com/this/goes/.../on/with/XXX.html" }
      # end
    end

    # context "when URL is too long and has at least one sublevel specified as well as a query parameter" do
    #   let(:shortened) { Truncator::UrlParser.shorten_url("http://www.foo.com/this/goes/on/and/on/and/on/and/on/and/ends/with/XXXX.html?q=1&a=2&b=3", 50) }

    #   it "should replace path segments with ellipses to shorten the path as much as necessary, and show only the first param, followed by ellipses" do
    #     shortened.should == "www.foo.com/this/goes/.../with/XXXX.html?q=1..."
    #   end
    # end

    context "when URL is more than 30 chars long and does not have at least one sublevel specified" do
      let(:shortened) { Truncator::UrlParser.shorten_url("http://www.mass.gov/?pageID=trepressrelease&L=4&L0=Home&L1=Media+%26+Publications&L2=Treasury+Press+Releases&L3=2006&sid=Ctre&b=pressrelease&f=2006_032706&csid=Ctre", 30) }

      it "should truncate to 30 chars with ellipses" do
        shortened.should == "www.mass.gov/?pageID=trepre..."
      end
    end

    context "when the URL contains a really long host name and a long trailing filename" do
      let(:shortened) { Truncator::UrlParser.shorten_url("http://www128376218.skjdhfskdjfhs.lqdkwjqlkwjdqlqwkjd.com/some/path/1234567890123456789012345678901234test_of_the_mergency_broadcastingnet_work.html", 30) }

      it "should not truncate the host name and truncated the last part of the path to truncation length and all dirs" do
        shortened.should == "www128376218.skjdhfskdjfhs.lqdkwjqlkwjdqlqwkjd.com/.../123456789012345678901234567..."
      end
    end

    #TODO: this and the next spec can be merged
    context "when the URL contains a really long host name and is an http url and has an empty path" do
      let(:shortened) { Truncator::UrlParser.shorten_url("http://www128376218.skjdhfskdj.lqdkwjqlkwjdqlqwkjd.com/", 30) }

      it "should truncate the host name and have no trailing /" do
        shortened.should == "www128376218.skjdhfskdj.lqd..."
      end
    end

    context "when the URL contains a really long host name and is an http url and has an empty path and no trailing /" do
      let(:shortened) { Truncator::UrlParser.shorten_url("http://www128376218.skjdhfskdj.lqdkwjqlkwjdqlqwkjd.com", 30) }

      it "should truncate the URL and have no trailing /" do
        shortened.should == "www128376218.skjdhfskdj.lqd..."
      end
    end

    context "when the URL contains a really long host name and has a really long query parameter" do
      let(:shortened) { Truncator::UrlParser.shorten_url("http://www128376218.skjdhfskdjfhs.lqdkwjqlkwjdqlqwkjd.com/?cmd=1234567890123456789012345678901234&api_key=1234567890123456789012345678901234", 30) }

      it "should not truncate the host name but truncate the query parameter" do
        shortened.should == "www128376218.skjdhfskdjfhs.lqdkwjqlkwjdqlqwkjd.com/?cmd=1234567890123456789012..."
      end
    end

    context "when URL is really short and contains only the protocol http and hostname" do
      let(:shortened) { Truncator::UrlParser.shorten_url("http://bit.ly/") }

      it "should omit the protocol as well as trailing slash" do
        shortened.should == "bit.ly"
      end
    end

    context "when URL is really short and contains only the protocol http and hostname and a long query parameter" do
      let(:shortened) { Truncator::UrlParser.shorten_url("http://api.bit.ly/?cmd=boom&t=now&auth_token=f886c1c02896492577e92b550cd22b3c83b062") }

      it "should omit the protocol as well as trailing slash" do
        shortened.should == "api.bit.ly/?cmd=boom&t=now&auth_token=f..."
      end
    end

    context "when URL is really short and contains only the protocol http and hostname and a short query parameter" do
      let(:shortened) { Truncator::UrlParser.shorten_url("http://api.bit.ly/?cmd=boom&t=now") }

      it "should omit the protocol as well as trailing slash" do
        shortened.should == "api.bit.ly/?cmd=boom&t=now"
      end
    end

    context "when the URL starts with something other than http://hostname/" do
      before do
        @long_urls = [
            "https://www.mass.gov/",
            "http://www.mass.gov:81/",
            "http://user:secret@www.mass.gov/",
            "https://www.mass.gov/?pageID=trepressrelease&L=4&L0=Home&L1=Media+%26+Publications&L2=Treasury+Press+Releases&L3=2006&sid=Ctre&b=pressrelease&f=2006_032706&csid=Ctre",
            "http://www.mass.gov:81/?pageID=trepressrelease&L=4&L0=Home&L1=Media+%26+Publications&L2=Treasury+Press+Releases&L3=2006&sid=Ctre&b=pressrelease&f=2006_032706&csid=Ctre",
            "http://user:secret@www.mass.gov/?pageID=trepressrelease&L=4&L0=Home&L1=Media+%26+Publications&L2=Treasury+Press+Releases&L3=2006&sid=Ctre&b=pressrelease&f=2006_032706&csid=Ctre",
            "ftp://www.mass.gov/"
        ]
        @short_urls = [
            "https://www.mass.gov/",
            "http://www.mass.gov:81/",
            "http://user:secret@www.mass.gov/",
            "https://www.mass.gov/?pageID=trepressrelease...",
            "http://www.mass.gov:81/?pageID=trepressrelease...",
            "http://user:secret@www.mass.gov/?pageID=trepressrelease...",
            "ftp://www.mass.gov/"
        ]
      end

      it "should truncate to 30 chars with ellipses" do
        @long_urls.each_with_index do |url, x|
          Truncator::UrlParser.shorten_url(url, 30).should == @short_urls[x]
        end
      end
    end
  end

end
