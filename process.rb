#!/usr/bin/env ruby

require 'yaml'
require 'fileutils'
require 'erb'

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
yConfig = YAML::load(ERB.new(config).result)

yConfig['env'].each do | env | 
  output = String.new content
  output_file = "#{output_dir}/#{env}/#{File.basename(filename, '.*')}"
  FileUtils.mkdir_p File.dirname(output_file)

  File.open(output_file, 'w') do |output_config| 
    yConfig['vars'].each { |key, value| output.gsub! Regexp.new("%#{key}%"), value[env] || value['default'] }
    output_config << output
  end
end