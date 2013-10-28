#!/usr/bin/env ruby

require 'yaml'
require 'fileutils'
require 'erb'

def load_template(file)
  content, config, reading_config = '', '', false

  File.open(file).each_line do |s|
    (reading_config = true; next) if s =~ /^__CONFIG__/ 
    (reading_config ? config : content) << s
  end

  [content, YAML::load(ERB.new(config).result)]
end

def file_autocreate(path)
  directory = File.dirname(path)
  FileUtils.makedirs(directory) unless File.exists?(directory)

  File.open(path, 'w') do |file|
    yield(file) if block_given?
  end
end

output_dir = "build"
filename = ARGV[0]
content, config = load_template(filename)

config['env'].each do | env | 
  output = String.new content
  output_path = "#{output_dir}/#{env}/#{File.basename(filename, '.*')}"

  file_autocreate(output_path) do |file| 
    config['vars'].each { |key, value| output.gsub! Regexp.new("%#{key}%"), value[env] || value['default'] }
    file << output
  end
end