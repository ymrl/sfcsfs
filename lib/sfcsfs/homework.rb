#coding:utf-8

module SFCSFS
  class Homework
    def initialize(title,url)
      @title = title.to_s
      @url   = url.to_s
    end
    attr_accessor :title,:url
  end
end

