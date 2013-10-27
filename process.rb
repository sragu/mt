#!/usr/bin/env ruby

require 'yaml'
require 'fileutils'

def load_config(file)
  content, config, reading_config = '', '', false

  File.open(file).each_line do |s|
    if s =~ /^__CONFIG__/
      reading_config = true
      next 
    end

    (reading_config ? config : content) << s
  end

  [content, config]
end

output_dir = "build"
filename = ARGV[0]
content, config = load_config(filename)
yConfig = YAML::load(config)

yConfig['env'].each do | env | 
  output = String.new content
  FileUtils.mkdir_p("#{output_dir}/#{env}")
  File.open("#{output_dir}/#{env}/#{filename}", 'w') do |output_config| 
    yConfig['vars'].each { |varname| output.gsub!(Regexp.new(varname[0]), varname[1][env]) }
    output_config << output
  end
end