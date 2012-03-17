require './' + File.dirname(__FILE__) + '/../lib/sfcsfs.rb'
require 'pit'
desc "Add All Lectures of Next Semester"
task :addnext do
  config = Pit.get("sfcsfs", :require => {
      :account  => "your CNS account",
      :password => "your CNS password"
  })
  agent = SFCSFS.login(config[:account],config[:password])
  list = agent.get_class_list_of_next_semester
  list.each do |lecture|
    puts "#{lecture.title} (#{lecture.instructor})"
    agent.get lecture.add_list_url
  end
end

