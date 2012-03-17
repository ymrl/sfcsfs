#coding:utf-8
require 'rake'
$:.unshift File.join(File.dirname(__FILE__),'lib')

require 'rspec/core'
require 'rspec/core/rake_task'

task :default => :spec
Dir['tasks/**/*.rake'].each { |t| load t}
