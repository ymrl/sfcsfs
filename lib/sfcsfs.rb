#coding:utf-8
$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))
  
directory = File.expand_path(File.dirname(__FILE__))

require directory+'/sfcsfs/lecture.rb'
require directory+'/sfcsfs/homework.rb'
require directory+'/sfcsfs/agent.rb'


module SFCSFS
  VERSION = '0.0.1'
end