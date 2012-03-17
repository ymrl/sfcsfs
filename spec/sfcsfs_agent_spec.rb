#coding:utf-8

require File.dirname(__FILE__) + '/spec_helper.rb'
require File.dirname(__FILE__) + '/../lib/sfcsfs.rb'

describe 'Agent' do
  before do
    config = Pit.get("sfcsfs", :require => {
        :account  => "your CNS account",
        :password => "your CNS password"
    })
    @agent = SFCSFS.login(config[:account],config[:password])
  end
  it 'URLがs01.cgiにいる' do
    @agent.page.uri.to_s.match(%r!^https://vu.\.sfc\.keio\.ac\.jp/sfc-sfs/portal_s/s01\.cgi.*!).should be_true
  end
  
  it 'query_valuesがセットされている' do
    @agent.query_values.should be_true
    @agent.query_values['id'].should be_true
  end

  it '次学期プランページへのアクセス' do
    @agent.get_plans_page_of_next_semester
  end

  context '次学期プランの履修' do
    it '科目一覧の取得' do
      list = @agent.get_class_list_of_next_semester
      list.each do |e|
        e.should be_instance_of(SFCSFS::Lecture)
        e.add_list_url.should be_true
      end
    end
  end


  context 'my時間割にアクセスする' do
    before do
      @lectures = @agent.my_schedule
    end
    it 'Lectureが生成されている' do
      @lectures.each do |e|
        e.should be_instance_of(SFCSFS::Lecture)
        e.instructor.should have_at_least(1).items
        e.mode.should be_true
        e.query.should be_instance_of(Hash)
        e.homeworks.should be_instance_of(Array)
      end
    end
    it 'Lectureから残留届けページヘ行ける' do
      @lectures.each {|e| e.get_stay_input_page(@agent)}
    end
    it 'Lecture#instructorが括弧とか\sとか含まない' do
      @lectures.each { |e| (e.instructor.match(/[()（）\s]/)).should be_false }
    end
    it 'Lecture#queryがidを含まない' do
      @lectures.each { |e| (e.query["id"]).should be_false }
    end
    it 'Lectureのclass_top_url_attributesが取得できる' do
      @lectures.each {|e| e.class_top_url_attributes }
    end
    it 'Lectureそれぞれに詳細情報を取得できる' do
      @lectures.each do |e| e.get_detail(@agent) 
        e.homeworks.each do |h|
          h.should be_instance_of(SFCSFS::Homework)
          h.title.should have_at_least(1).items
          h.title.match(/^「/).should be_false
          h.title.match(/」$/).should be_false
          h.url.match(%r{.*\.sfc\.keio\.ac\.jp/sfc-sfs/sfs_class/report/report.cgi\?}).should be_true
        end
      end
    end
    
  end
end


