require './' + File.dirname(__FILE__) + '/../lib/sfcsfs.rb'
require 'pit'
desc "Add All Lectures of Next Semester"

task :addnext do
  config = Pit.get("sfcsfs", :require => {
      :account  => "your CNS account",
      :password => "your CNS password"
  })
  agent = SFCSFS.login(config[:account],config[:password])
  list = agent.all_classes_of_next_semester
  list.each do |lecture|
    puts "#{lecture.title} (#{lecture.instructor})"
    retry_count = 0
    begin
      lecture.add_to_plan
    rescue
      sleep 60
      retry_count += 1
      if retry_count < 10
        retry
      end
    end
  end
end

desc "Add All Lectures of this Semester"
task :addall do
  config = Pit.get("sfcsfs", :require => {
      :account  => "your CNS account",
      :password => "your CNS password"
  })
  agent = SFCSFS.login(config[:account],config[:password])
  list = agent.all_classes_of_this_semester
  list.each do |lecture|
    puts "#{lecture.title} (#{lecture.instructor})"
    retry_count = 0
    begin
      lecture.add_to_plan
    rescue
      sleep 60
      retry_count += 1
      if retry_count < 10
        retry
      end
    end
  end
end

