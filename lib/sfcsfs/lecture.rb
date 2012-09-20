#coding:utf-8
module SFCSFS
  class Lecture
    def initialize(agent,title,instructor,config={})
      @agent = agent
      @title = title
      @instructor = instructor
      @instructors = config[:instructors] || []
      @mode  = config[:mode]
      @yc    = config[:yc]
      @ks    = config[:ks]
      @reg   = config[:reg]
      @term  = config[:term]
      @homeworks = config[:homeworks] || []
      @periods = config[:periods] || []
      @applicants = config[:applicants]
      @limit = config[:limit]
      @place = config[:place]
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
      @title = doc.search('h3.one').first.children.first.to_s.gsub(/[\s　]/,'')
      @instructors += doc.search('h3.one > a[href]').to_a.delete_if{|e| !e.attr('href').match(/profile\.cgi/)}.map{|e|e.children.first.to_s}
      @instructors.uniq!
      term = doc.search('h3.one .ja').text.match(/(\d{4})年度([春秋])学期(.*)$/u)
      if term
        @term = "#{term[1]}#{term[2] == '春' ? 's' : 'f'}"
        @periods += term[3].gsub(/\s/,'').split(/\//)
        @periods.uniq!
      end
      page = doc.to_s
      #a.doc.search('a').to_a.delete_if{|e|!e.attributes['href'].match(%r{/report/report\.cgi\?})}.each do |e|
      #  # TODO : Homeworks Func
      #end
      if m = page.match(/履修希望者数：(\d+)/u)
        @applicants = m[1].to_i
      end
      if m = page.match(/受入学生数（予定）：約 (\d+) 人/u)
        @limit = m[1].to_i
      end
      return self
    end

    def student_selection_list
      uri = @agent.base_uri + student_selection_path
      doc = @agent.request_parse(uri)
      return doc.search('tr[bgcolor="#efefef"] td').map{|e| e.children.first.to_s}.delete_if{|e| !e.match(/^\d{8}/)}
    end

    def get_stay_input_page
      uri = @agent.base_uri + stay_input_path
      @agent.request_parse(uri)
    end
    def submit_stay_form data
      param = {}
      uri = @agent.base_uri + '/sfc-sfs/sfs_class/stay/stay_input.cgi'
      unless @yc && @ks && @aget.id
        raise NotEnoughParamsException
      end
      param[:stay_phone]      = data[:stay_phone]
      param[:stay_p_phone]    = data[:stay_p_phone]
      param[:stay_time]       = data[:stay_time]
      param[:selectRoom]      = data[:selectRoom]
      param[:selectFloor]     = data[:selectFloor]
      param[:stay_room_other] = data[:stay_room_other]
      param[:stay_reason]     = data[:stay_reason]
      param[:mode] = 'submit'
      param[:yc] = @yc
      param[:ks] = @ks
      param[:enc_id] = @agent.id
      request uri,:post,data
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

    attr_accessor :title,:instructor,:mode,:yc,:ks,:homeworks,
                  :add_list_url,:periods,:applicants,:limit,
                  :reg,:term, :place
  end

  class NotEnoughParamsException < Exception
  end
end
