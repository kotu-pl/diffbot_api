require "json"
require "open-uri"

module Diffbot
  ARTICLE_V2_URL = "http://api.diffbot.com/v2/article"
  #shared accross instances
  @@token = nil

  def self.token
    @@token
  end

  def self.token=(value)
    @@token = value
  end

  #TODO: include Enumerable
  class ArticleAPI
    attr_accessor :token, :url, :fields, :timeout, :callback, :result

    def initialize(args = {})
      self.token = args.fetch(:token, Diffbot.token)
      self.url = args[:url]
      raise ArgumentError, "TOKEN not provided" unless self.token
      raise ArgumentError, "URL(s) not provided" unless self.url

      self.fields = args[:fields] || nil
      self.timeout = args[:timeout] || nil
      self.callback = args[:callback] || nil

      self.result = nil
    end

    # do real items processing
    def process
      q = self.dup
      q.process!
    end

    def process!
      @result = JSON.load(open(Diffbot::ARTICLE_V2_URL  + "?token=#{token}&url=#{url}"))
      self
    end

    def to_s
      @result ? "Result for #{url} => #{@result}" : "No results fetched yet"
    end

    #static function
    class << self

    end
  end

  class DiffbotEnumerator
    include Enumerable
    attr_reader :items
    def initialize(items = nil)
      @items = items ? items : []
    end
    def each(&block)
      @items.each do |item|
        if block_given?
          block.call item
        else
          yield item
        end
      end
    end
    def <<(value)
      @items << value
    end
  end
end

Diffbot::token = ''

urls = %w(http://www.webmonkey.com/2013/04/nginx-speeds-up-the-tubes-with-spdy-support http://techcrunch.com/2014/01/02/join-us-for-hardware-battlefield-where-martha-stewart-and-our-other-celebrity-judges-will-pick-the-best-hardware-startup-of-the-year http://techcrunch.com/2014/01/02/go-ahead-ces-2014-prove-theres-tech-i-want-to-wear http://techcrunch.com/2014/01/03/kiwi-puts-its-all-purpose-wearable-up-for-pre-order-aims-to-be-everything-to-everyone)
puts "Direct, one element, fetch:"
puts Diffbot::ArticleAPI.new(url: urls.last).process
puts '--------------'

multiple_enumareble = Diffbot::DiffbotEnumerator.new
urls.each do |u|
  multiple_enumareble << Diffbot::ArticleAPI.new(url: u).process
end

puts "All items:"
multiple_enumareble.each { |item| puts item }
puts '--------------'

puts "Searching for items 'webmonkey.com' item:"
puts multiple_enumareble.find_all { |result| result.url =~ /webmonkey.com/ }
puts '--------------'

