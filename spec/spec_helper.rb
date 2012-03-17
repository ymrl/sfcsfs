#coding:utf-8
$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')
$:.unshift File.expand_path(File.join(File.dirname(__FILE__)))

Dir[File.join(File.dirname(__FILE__), "..", "lib", "models", "**/*.rb")].each do |f|
  require f
end
require 'pit'
