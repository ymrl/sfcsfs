#coding:utf-8
module SFCSFS
  class Lecture
    def initialize(title,instructor,hash)
      config = { :mode => nil , :query => nil,:homeworks => [],:add_list_url=>nil}.merge(hash)
      self.title = title.gsub(/^[　\s]*/,'').gsub(/[　\s]*$/,'')
      self.instructor = instructor.gsub(/[()\s　]/,'')
      self.mode = config[:mode]
      self.query = config[:query]
      self.homeworks = config[:homeworks]
      self.add_list_url = config[:add_list_url]
    end
    def class_top_url_attributes
      mode = 'student'
      file = 's_class_top.cgi'
      type = "s"
      if(self.mode == 'faculty')
        mode = 'faculty'
        file = 'f_class_top.cgi'
        type = "t"
      end
      return {
        :path => "/sfc-sfs/sfs_class/#{mode}/#{file}",
        :query => self.query.merge("type" => type),
      }
    end
    def get_detail(agent)
      agent.get_lecture_detail(self)
    end
    def get_stay_input_page(agent)
      agent.get_stay_input_page(self)
    end
    attr_accessor :title,:instructor,:mode,:query,:homeworks,:add_list_url
  end
end
