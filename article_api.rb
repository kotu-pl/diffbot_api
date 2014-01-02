require "json"
require "httparty"

module Diffbot
  ARTICLE_V2_URL = "http://api.diffbot.com/v2/article".to_sym
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
    attr_accessor :url, :fields, :timeout, :callback

    def initialize(args = {})
      raise ArgumentError, "TOKEN not provided" unless args.fetch(:token, Diffbot.token)
      raise ArgumentError, "URL(s) not provided" unless args[:url]
      self.fields = args[:fields] || nil
      self.timeout = args[:timeout] || nil
      self.callback = args[:callback] || nil
    end

    # do real items processing
    def process

    end

    #static function
    class << self

    end
  end

end

Diffbot::token = 444
article_api = Diffbot::ArticleAPI.new(url: 'http://www.wired.co.uk/reviews/mobile-phones/')

