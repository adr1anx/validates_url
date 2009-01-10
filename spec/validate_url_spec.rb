require File.dirname(__FILE__) + '/spec_helper'

class User < ActiveRecord::Base
  validate_url :required_url
  validate_url :blank_url, :allow_blank => true
  validate_url :nil_url, :allow_nil => true, :check_http => true
end

describe "validate url format" do
  
  before :each do
    @user = User.new({:required_url => "http://www.example.com",
                      :blank_url => "",
                      :nil_url => nil})
  end

  it "should allow blank url with blank_url set" do
    @user.blank_url = ""
    @user.save
    @user.errors.on(:blank_url).should be_nil
  end
  
  it "should allow nil url with allow_nil set" do
    @user.nil_url = nil
    @user.save
    @user.errors.on(:nil_url).should be_nil
  end
  
  describe "should allow valid url formats" do
    [ 'http://example.com',
      'http://example.com/',
      'http://www.example.com/',
      'http://sub.domain.example.com/',
      'http://bbc.co.uk',
      'http://example.com?foo',
      'http://example.com?url=http://example.com',
      'http://example.com:8000',
      'http://www.sub.example.com/page.html?foo=bar&baz=%23#anchor',
      'http://user:pass@example.com',
      'http://user:@example.com',
      'http://example.com/~user',
      'http://example.xy', # Not a real TLD, but we're fine with anything of 2-6 chars
      'http://example.museum',
      'http://1.0.255.249',
      'http://1.2.3.4:80',
      'HttP://example.com',
      'https://example.com',
      'http://räksmörgås.nu', # IDN
      'http://xn--rksmrgs-5wao1o.nu', # Punycode
      'http://example.com.', # Explicit TLD root period
      'http://example.com./foo'
    ].each do |url|
      it "'#{url}'" do
        lambda do
          @user.required_url = url
          @user.save
          @user.errors.on(:required_url).should be_nil
        end.should change(User,:count).by(1)
      end
    end
  end
  
  describe "should disallow invalid url formats" do
    [
      nil, 1, "", " ", "url",
      "www.example.com",
      "http://ex ample.com",
      "http://example.com/foo bar",
      'http://256.0.0.1',
      'http://u:u:u@example.com',
      'http://r?ksmorgas.com',
      
      # These can all be valid local URLs, but should not be considered valid
      # for public consumption.
      "http://example",
      "http://example.c",
      'http://example.toolongtld'
    ].each do |url|
      it "'#{url}'" do
        @user.required_url = url
        @user.save
        @user.errors.on(:required_url).should_not be_nil
      end
    end
  end
end

describe "validates the url is an actual web page" do
  before :each do
    @user = User.new({:required_url => "http://www.example.com",
                      :blank_url => "",
                      :nil_url => nil})

    @mock_success = mock("Net::HTTPSuccess",:null_object=>true)
    @mock_success.stub!(:is_a?).and_return(Net::HTTPSuccess)
    @mock_fail = mock("Net::HTTPNotFound",:null_object=>true)
    
  end
  
  it "should throw  error with a url that doesn't resolve" do
    Net::HTTP.should_receive('get_response').with(URI.parse("http://www.example.com/d")).and_return(@mock_fail)
      
    @user.nil_url = "http://www.example.com/d"
    @user.save
    @user.errors.on(:nil_url).should_not be_nil
    @user.errors.on(:nil_url).should eql("does not resolve")
  end
  
  it "should not throw an error with a url that does resolve" do
    Net::HTTP.should_receive('get_response').with(URI.parse("http://www.example.com")).and_return(@mock_success)
    
    @user.nil_url = "http://www.example.com"
    @user.save
    @user.errors.on(:nil_url).should be_nil
  end
end
