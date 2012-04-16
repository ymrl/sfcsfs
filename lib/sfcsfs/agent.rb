#coding:utf-8
require 'hpricot'
require 'uri'
require 'net/https'
require 'addressable/uri'

module SFCSFS
  REDIRECT_LIMIT = 5
  def SFCSFS.login(account,passwd)
    return Agent.login(account,passwd)
  end
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
        req.set_form_data(data) if data.length > 0
        http = Net::HTTP.new(uri.host,uri.port)
        http.use_ssl = true if uri.scheme == 'https'
        http.start{|http| ret = http.request(req)}
        @uri = uri
        uri = ret['location'] if ret['location']
        count += 0
      end
      if count >= REDIRECT_LIMIT
        raise TooManyRedirectionException
      end
      return ret
    end
    def request_parse uri,method=:get,data={}
      uri = (URI::Generic === uri ? uri : URI.parse(uri))
      r = request(uri,method,data)
      @doc = Hpricot(r.body.force_encoding(Encoding::EUC_JP).encode(Encoding::UTF_8,:invalid=>:replace,:undef=>:replace)) 
      if meta = @doc.search('meta["http-equiv"="refresh"]')
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

    def plan_of_this_semester
      get_plans_page_of_this_semester
      plan_list_from_plans_page
    end

    def plan_of_next_semester
      get_plans_page_of_next_semester
      plan_list_from_plans_page
    end

    def all_classes_of_this_semester
      get_plans_page_of_this_semester
      all_classes_from_plans_page
    end

    def all_classes_of_next_semester
      get_plans_page_of_next_semester
      all_classes_from_plans_page
    end


    def get_plans_page_of_this_semester
      outer_uri = @base_uri + 
        "/sfc-sfs/portal_s/s02.cgi?id=#{@id}&type=#{@type}&mode=1&lang=ja"
      request_parse(outer_uri)
      inner_uri = outer_uri + @doc.search('iframe').attr('src')
      request_parse(inner_uri)
    end

    def get_plans_page_of_next_semester
      outer_uri = @base_uri + 
        "/sfc-sfs/portal_s/s02.cgi?id=#{@id}&type=#{@type}&mode=2&lang=ja"
      request_parse(outer_uri)
      inner_uri = outer_uri + @doc.search('iframe').attr('src')
      request_parse(inner_uri)
    end

    def all_classes_from_plans_page
      list = []
      uri = @uri
      @doc.search('a').to_a.delete_if{|e| !e.attributes['href'].match(/class_list\.cgi/)}.each do |e|
        request_parse uri+e.attributes['href']
        @doc.search('a').to_a.delete_if{|e| !e.attributes['href'].match(/plan_list\.cgi/)}.each do |e|
          str = e.parent.innerText
          title = nil
          instructor = nil
          if match = str.match(/：\d+\(.+?\) … (.+?) \((.+?)\)…/)
            title = match[1]
            instructor = match[2]
          end
          q = Addressable::URI.parse(e.attributes['href']).query_values 
          ks = q['ks']
          yc = q['yc']
          reg = q['reg']
          term = q['term']
          list.push Lecture.new(self,title,instructor,:ks=>ks,:yc=>yc,:reg=>reg,:term=>term)
        end
      end
      return list
    end

    def plan_list_from_plans_page
      @doc.search('a').to_a.delete_if{|e| !e.attributes['href'].match(/syll_view.cgi/)}.map do |e|
        href = e.attributes['href']
        q = Addressable::URI.parse(href).query_values 
        ks = q['ks']
        yc = q['yc']
        title = e.children.first.to_s
        Lecture.new(self,title,nil,:ks=>ks,:yc=>yc)
      end
    end

    def my_schedule
      outer_uri = @base_uri +
        "/sfc-sfs/portal_s/s01.cgi?id=#{@id}&type=#{@type}&mode=1&lang=ja"
      request_parse outer_uri
      inner_uri = @uri + @doc.search('iframe').attr('src')
      request_parse inner_uri

      @doc.search('table a').to_a.delete_if{|e|
        !e.attributes["href"].match(/sfs_class/)
      }.map do |e|
        href = e.attributes["href"]
        mode = href.match(/faculty/) ? 'faculty' : 'student'
        q = Addressable::URI.parse(href).query_values 
        ks = q['ks']
        yc = q['yc']
        title = e.children.first.to_s
        instructor = e.next.next.to_s.gsub(/[()\s　]/,'')
        Lecture.new(self,title,instructor, :mode => mode, :ks=>ks, :yc=>yc)
      end
    end

    attr_accessor :login,:query_values,:base_uri,:doc,:id,:uri,:type
  end
  class TooManyRedirectionException < Exception
  end
end
