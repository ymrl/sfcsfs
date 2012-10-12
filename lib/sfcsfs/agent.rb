#coding:utf-8
require 'nokogiri'
require 'uri'
require 'net/https'
require 'addressable/uri'

module SFCSFS
  REDIRECT_LIMIT = 5

  class Agent

    def inspect
      "#{self.class} #{@id}"
    end

    def request uri,method=:get,data={}
      ret = nil
      count = 0
      while count < REDIRECT_LIMIT and !ret or Net::HTTPRedirection === ret
        uri = (URI::Generic === uri ? uri : URI.parse(uri))
        req = nil
        uri += '/' if uri.path == ''
        path = uri.path
        path += "?#{uri.query}" if uri.query && uri.query.length > 0
        if method.to_sym == :post
          req = Net::HTTP::Post.new(path)
        else
          req = Net::HTTP::Get.new(path)
        end
        if data.length > 0
          data.each_pair do |k,v|
            data[k] = SFCSFS.convert_encoding_for_send(v)
          end
          req.set_form_data(data) 
        end
        http = Net::HTTP.new(uri.host,uri.port)
        http.use_ssl = true if uri.scheme == 'https'
        http.start{|http| ret = http.request(req)}
        @uri = uri
        uri = ret['location'] if ret['location']
        count += 0
      end
      if count >= REDIRECT_LIMIT
        raise TooManyRedirectionsException
      end
      return ret
    end

    def request_parse uri,method=:get,data={}
      uri = (URI::Generic === uri ? uri : URI.parse(uri))
      r = request(uri,method,data)
      @doc = Nokogiri.HTML(SFCSFS.convert_encoding(r.body),nil,'UTF-8')
      if meta = @doc.search('meta[http-equiv=refresh]').first
        match = meta.attr('content').match(/url=(.*)$/)
        if match
          request_parse(@uri+match[1])
        end
      end
      return @doc
    end

    def initialize
      @uri  = nil
      @doc  = nil
      @id   = nil
      @base_uri = nil
      @type = nil
      return self
    end
    def logout
      request @base_uri + "/sfc-sfs/logout.cgi?id=#{@id}&type=#{@type}&lang=ja"
    end

    def Agent.login(account,passwd,options={})
      a = Agent.new
      doc = a.request_parse('https://gc.sfc.keio.ac.jp/sfc-sfs/')
      action = doc.search('form').attr('action')
      a.request_parse(action,:post,:u_login => account, :u_pass => passwd)
      query_values = Addressable::URI.parse(a.uri).query_values 
      a.id = query_values['id']
      a.type = query_values['type']

      if options[:vu9]
        a.base_uri = URI.parse('https://vu9.sfc.keio.ac.jp/')
      else
        a.base_uri = a.uri + '/'
      end

      return a
    end
    attr_accessor :login,:query_values,:base_uri,
                  :doc,:id,:uri,:type
  end
  class TooManyRedirectionsException < Exception
  end
end
