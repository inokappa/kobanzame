require 'optparse'
require 'kobanzame/version'
require 'kobanzame/collector'

op = OptionParser.new
op.version = Kobanzame::VERSION

opts = {
  config: 'kobanzame.json',
  pid_file: 'kobanzame.pid',
  log_file: 'kobanzame.log',
  daemonize: false,
  debug: false
}

op.on('-c', '--config PATH', "config file path (default: #{opts[:config]})") {|v|
  opts[:config] = v
}

op.on('-d', '--daemonize', "enable daemonize (default: #{opts[:daemonize]})") {|v|
  opts[:daemonize] = v
}

op.on('-p', '--pid-file PATH', "pid file path (default: #{opts[:pid_file]})") {|v|
  opts[:pid_file] = v
}

op.on('-l', '--log-file PATH', "log file path (default: #{opts[:log_file]})") {|v|
  opts[:log_file] = v
}

op.on('-D', '--debug', "start with debug mode (default: #{opts[:debug]})") {|v|
  opts[:debug] = v
}

begin
  op.parse(ARGV)
rescue OptionParser::InvalidOption => ex
  puts op.to_s
  puts "error: #{ex.message}"
  exit 1
end

k = Kobanzame::Collector.new(opts)
k.start
