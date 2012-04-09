#coding:utf-8
module SFCSFS
  class Lecture
    def initialize(agent,title,instructor,hash = {})
      config = {:homeworks => [],:period=>[]}.merge(hash)
      @agent = agent
      @title = title
      @instructor = instructor
      @mode  = config[:mode]
      @yc    = config[:yc]
      @ks    = config[:ks]
      @reg   = config[:reg]
      @term  = config[:term]
      @homeworks = config[:homeworks]
      @period = config[:period]
      @applicants = config[:applicants]
      @limit = config[:limit]
    end
    def inspect
      "#{self.class} \"#{@title}\" \"#{@instructor}\" #{@yc} #{@ks}"
    end
    def class_top_path
      unless @yc && @ks && @agent.id
        raise NotEnoughParamsException
      end
      mode = 'student'
      file = 's_class_top.cgi'
      if(self.mode == 'faculty')
        mode = 'faculty'
        file = 'f_class_top.cgi'
      end
      return "/sfc-sfs/sfs_class/#{mode}/#{file}?lang=ja&ks=#{@ks}&yc=#{@yc}&id=#{@agent.id}"
    end
    def stay_input_path
      unless @yc && @ks && @agent.id
        raise NotEnoughParamsException
      end
      "/sfc-sfs/sfs_class/stay/stay_input.cgi?yc=#{@yc}&ks=#{@ks}&enc_id=#{@agent.id}"
    end
    def student_selection_path
      unless @yc && @agent.id
        raise NotEnoughParamsException
      end
      "/sfc-sfs/sfs_class/student/view_student_select.cgi?enc_id=#{@agent.id}&yc=#{@yc}&lang=ja"
    end

    def get_detail
      uri = @agent.base_uri + class_top_path
      doc = @agent.request_parse(uri)
      page = doc.to_s
      #a.doc.search('a').to_a.delete_if{|e|!e.attributes['href'].match(%r{/report/report\.cgi\?})}.each do |e|
      #  # TODO : Homeworks Func
      #end
      if m = page.match(/履修希望者数：(\d+)/)
        @applicants = m[1].to_i
      end
      if m = page.match(/受入学生数（予定）：約 (\d+) 人/)
        @limit = m[1].to_i
      end
      return self
    end

    def student_selection_list
      uri = @agent.base_uri + student_selection_path
      doc = @agent.request_parse(uri)
      return doc.search('tr[@bgcolor="#efefef"] td').map{|e| e.children.first.to_s}.delete_if{|e| !e.match(/^\d{8}/)}
    end

    def get_stay_input_page
      uri = @agent.base_uri + stay_input_path
      @agent.request_parse(uri)
    end

    def add_to_plan
      unless @reg && @yc && @ks && @agent.id && @term
        raise NotEnoughParamsException
      end
      uri = @agent.base_uri + "/sfc-sfs/sfs_class/student/plan_list.cgi?reg=#{@reg}&yc=#{@yc}&mode=add&ks=#{@ks}&id=#{@agent.id}&term=#{@term}&lang=ja"
      @agent.request(uri)
    end

    def delete_from_plan
      unless @yc && @ks && @agent.id && @term
        raise NotEnoughParamsException
      end
      uri = @agent.base_uri + "/sfc-sfs/sfs_class/student/plan_list.cgi?reg=#{@reg}&yc=#{@yc}&mode=del&ks=#{@ks}&id=#{@agent.id}&term=#{@term}&lang=ja"
      @agent.request(uri)
    end

    attr_accessor :title,:instructor,:mode,:yc,:ks,:homeworks,:add_list_url,:period,:applicants,:limit,:reg,:term
  end

  class NotEnoughParamsException < Exception
  end
end
