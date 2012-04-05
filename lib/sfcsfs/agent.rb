#coding:utf-8
require 'mechanize'
require 'addressable/uri'

module SFCSFS
  def SFCSFS.login(account,passwd)
    return Agent.login(account,passwd)
  end
  class Agent < Mechanize
    def initialize
      super
      self.follow_meta_refresh = true
      self.max_history = 1
      self.query_values = nil
      self.base_url = nil
      return self
    end
    def Agent.login(account,passwd)
      a = Agent.new
      a.get('https://gc.sfc.keio.ac.jp/sfc-sfs/')
      form = a.page.forms.first
      form['u_login'] = account
      form['u_pass']  = passwd
      form.submit
      u = a.page.uri
      a.query_values = Addressable::URI.parse(u).query_values 
      a.base_url = "#{u.scheme}://#{u.host}"
      return a
    end
    def get_plans_page_of_this_semester
      q = self.query_values.merge("mode"=>1).to_a.map{|e|e.join('=')}.join('&')
      get("#{self.base_url}/sfc-sfs/portal_s/s02.cgi?#{q}")
    end
    def get_plans_page_of_next_semester
      q = self.query_values.merge("mode"=>2).to_a.map{|e|e.join('=')}.join('&')
      get("#{self.base_url}/sfc-sfs/portal_s/s02.cgi?#{q}")
    end
    def get_class_list_of_plans_page
      self.page.iframes.first.click
      list = []
      self.page.links_with(:href=>/class_list\.cgi\?/).each do |link|
        link.click
        self.page.links_with(:href=>/class_summary_by_kamoku\.cgi/).each do |lec|
          title = lec.text
          instructor = lec.node.next.text.gsub(/^\((.*)\).*$/,'\\1')
          add_list_url = self.page.uri + lec.node.parent.search('a[href^="plan_list.cgi"]').first.attributes['href'].value
          list.push Lecture.new(title,instructor,
                                :add_list_url => add_list_url)
        end
      end
      return list
    end
    def get_class_list_of_next_semester
      get_plans_page_of_next_semester
      return get_class_list_of_plans_page
    end
    def get_class_list_of_this_semester
      get_plans_page_of_this_semester
      return get_class_list_of_plans_page
    end

    def my_schedule
      q = self.query_values.merge("mode"=>1).to_a.map{|e|e.join('=')}.join('&')
      get("#{self.base_url}/sfc-sfs/portal_s/s01.cgi?#{q}")
      self.page.iframes.first.click
      self.page.search('table a').to_a.delete_if{|e|
        !e.attributes["href"].text.match(/sfs_class/)
      }.map do |e|
        href = e.attributes["href"].text
        mode = href.match(/faculty/) ? 'faculty' : 'student'
        q = Addressable::URI.parse(href).query_values 
        q.delete("id")
        q.delete("lang")
        n = e
        while (n = n.next).name != 'text';next;end

        day = 0
        td = e.parent
        while td.name == td
          day += 1
          td = td.previous
        end
        period = 0
        tr = e.parent.parent
        
        Lecture.new(
          e.text.encode(Encoding::UTF_8),
          n.text.encode(Encoding::UTF_8).gsub(/[()\s　]/,''),
          :mode => mode, :query => q,:day=>day)
      end
    end
    def get_lecture_detail(lecture)
      get_lecture_detail_page(lecture)
      self.page.links_with(:href=>%r{/report/report\.cgi\?}).each do |e|
        t = e.text.gsub(/^「(.*)」$/,'\\1')
        u = self.page.uri + e.uri
        lecture.homeworks.push  Homework.new(t,u)
      end
      encoded = self.page.body.force_encoding(self.page.encoding).encode(Encoding::UTF_8,:invalid=>:replace, :undef=>:replace)
      if m = encoded.match(/履修希望者数：(\d+)/)
        lecture.applicants = m[1].to_i
      end
      if m = encoded.match(/受入学生数（予定）：約 (\d+) 人/)
        lecture.limit = m[1].to_i
      end

      return lecture



    end
    def get_lecture_detail_page(lecture)
      a = lecture.class_top_url_attributes
      q = self.query_values.merge(a[:query]).to_a.map{|e|e.join('=')}.join('&')
      get("#{self.base_url}#{a[:path]}?#{q}")
    end
    def get_stay_input_page(lecture)
      get_lecture_detail_page(lecture)
      self.page.forms.first.submit
      return self
    end

    attr_accessor :login,:query_values,:base_url
  end
end
