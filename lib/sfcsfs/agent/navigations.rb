#coding:UTF-8
class SFCSFS::Agent
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
    @doc.search('a[href]').to_a.delete_if{|e| !e.attr('href').match(/class_list\.cgi/)}.each do |e|
      request_parse uri+e.attr('href')
      @doc.search('a[href]').to_a.delete_if{|e| !e.attr('href').match(/plan_list\.cgi/)}.each do |e|
        str = e.parent.text
        title = nil
        instructor = nil
        if match = str.match(/：\d+\(.+?\) … (.+?) \((.+?)\)…/)
          title = match[1]
          instructor = match[2]
        end
        q = Addressable::URI.parse(e.attr('href')).query_values 
        ks = q['ks']
        yc = q['yc']
        reg = q['reg']
        term = q['term']
        list.push SFCSFS::Lecture.new(self,title,instructor,:ks=>ks,:yc=>yc,:reg=>reg,:term=>term)
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
      SFCSFS::Lecture.new(self,title,nil,:ks=>ks,:yc=>yc)
    end
  end

  def my_schedule
    outer_uri = @base_uri +
      "/sfc-sfs/portal_s/s01.cgi?id=#{@id}&type=#{@type}&mode=1&lang=ja"
    request_parse outer_uri
    inner_uri = @uri + @doc.search('iframe').attr('src')
    request_parse inner_uri

    @doc.search('table a[href]').to_a.delete_if{|e|
      !e.attr('href').match(/sfs_class/)
    }.map do |e|
      href = e.attr("href")
      mode = href.match(/faculty/) ? 'faculty' : 'student'
      q = Addressable::URI.parse(href).query_values 
      ks = q['ks']
      yc = q['yc']
      title = e.children.first.to_s
      instructor = e.next.next.to_s.gsub(/[()\s　]/,'')
      SFCSFS::Lecture.new(self,title,instructor, :mode => mode, :ks=>ks, :yc=>yc)
    end
  end
end
