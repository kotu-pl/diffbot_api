require "httparty"

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
    attr_accessor :token, :url, :options, :result

    def initialize(args = {})
      self.token = args.fetch(:token, Diffbot.token)
      self.url = args[:url]
      raise ArgumentError, "TOKEN not provided" unless self.token
      raise ArgumentError, "URL(s) not provided" unless self.url

      if args[:options]
        opt_keys = %i(fields timeout callback)
        self.options = Hash[args[:options].find_all{|k,v| opt_keys.include?(k)}]
      else
        self.options = nil
      end

      self.result = nil
    end

    # do real items processing
    def process
      q = self.dup
      q.process!
    end

    def process!
      query = {:token => token, :url => url}
      query.merge!(self.options) if self.options

      api_call = HTTParty.get(Diffbot::ARTICLE_V2_URL, :query =>  query)
      raise RuntimeError, "Wrong response code (not 200): #{api_call.code}" if api_call.code != 200

      @result = api_call.parsed_response
      self
    end

    def to_s
      @result ? "Result for #{url} => #{@result}" : "No results fetched yet"
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