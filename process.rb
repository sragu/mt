#!/usr/bin/env ruby

require 'yaml'
require 'fileutils'
require 'erb'

def extract_content_and_config(file)
  content, config_string = File.read(file).split(/^__CONFIG__$/, 2)
  config = YAML.safe_load(ERB.new(config_string).result, permitted_classes: [String, Symbol, Integer, Hash, Array, TrueClass, FalseClass], symbolize_names: true)
  [content.strip, config]
end

def generate_file(content, vars, output_path)
  env = vars[:env][:default]
  output = content.gsub(/\$\w+\b/) do |match|
    key = match[1..].to_sym
    (vars[key][env.to_sym] || vars[key][:default]).to_s.gsub(/\$env\b/, env)
  end
  FileUtils.mkdir_p(File.dirname(output_path))
  File.write(output_path, output)
  # puts output
  puts "Generated: #{output_path}"
end

def process_template(template_file, output_dir = 'build')
  content, config = extract_content_and_config(template_file)
  
  config[:env].each do |env|
    vars = config[:vars].merge(:env => { :default => env })
    output_path = File.join(output_dir, env, File.basename(template_file, '.*'))
    
    generate_file(content, vars, output_path)
  end
end

# Main execution
if $PROGRAM_NAME == __FILE__
  template_file, output_dir = ARGV
  unless template_file
    $stderr.puts "Usage: #{$PROGRAM_NAME} <template_file> [output_dir]"
    exit 1
  end
  process_template(template_file, output_dir)
end
