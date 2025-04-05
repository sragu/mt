#!/usr/bin/env ruby

require 'yaml'
require 'fileutils'
require 'erb'

def extract_content_and_config(file)
  content, config_string = File.read(file).split(/^__CONFIG__$/, 2)
  config = YAML.safe_load(ERB.new(config_string).result, permitted_classes: [String, Symbol, Integer, Hash, Array, TrueClass, FalseClass])
  [content.strip, config]
end

def generate_file(content, vars, env, output_path)
  output = content.gsub(/\$\w+\b/) do |match|
    key = match[1..]
    (vars[key][env] || vars[key]['default']).to_s.gsub(/\$env\b/, env)
  end

  FileUtils.mkdir_p(File.dirname(output_path))
  
  File.write(output_path, output)
  puts "Generated: #{output_path}"
end

def process_template(template_file, output_dir = 'build')
  content, config = extract_content_and_config(template_file)
  
  config['env'].each do |env|
    vars = config['vars'].merge('env' => env)
    output_path = File.join(output_dir, env, File.basename(template_file, '.*'))
    
    generate_file(content, vars, env, output_path)
  end
end

# Main execution
if $PROGRAM_NAME == __FILE__
  if ARGV.empty?
    $stderr.puts "Usage: #{$PROGRAM_NAME} <template_file> [output_dir]"
    exit 1
  end

  process_template(ARGV[0], ARGV[1])
end