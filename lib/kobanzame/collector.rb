module Kobanzame
  class Utilities
    def self.request(path)
      url = URI.parse(ENV['ECS_CONTAINER_METADATA_URI'] + '/' + path)
      req = Net::HTTP::Get.new(url.path)
      res = Net::HTTP.start(url.host, url.port) {|http|
        http.request(req)
      }
      return nil unless res.code == '200'
      JSON.parse(res.body)
    end
  end
end

module Kobanzame
  module Worker
    def calc_cpu_percent(current, previous, interval = 1000000000)
      # to Percent (x.x %)
      # refer to: https://github.com/mackerelio/mackerel-container-agent/blob/ce7cb283a3cdbc690127c6f67c44bdce7b140619/platform/ecs/metric.go#L112-L115
      ((current['cpu_usage']['total_usage'].to_f - previous['cpu_usage']['total_usage'].to_f) / interval.to_f * 100).round(3)
    end

    def calc_memory_size(memory_stat)
      # to Megabyte (x.xx MiB)
      # refer to: https://github.com/mackerelio/mackerel-container-agent/blob/ce7cb283a3cdbc690127c6f67c44bdce7b140619/platform/ecs/metric.go#L117-L119
      ((memory_stat['usage'] - memory_stat['stats']['cache']).to_f / (1024.0 * 1024.0)).round(3)
    end

    def describe_target_container
      # return Container Info
      res = Kobanzame::Utilities.request('task')
      return nil if res.nil?
      res
    end

    def describe_target_container_metrics(container_id)
      stat = nil
      res = Kobanzame::Utilities.request('task/stats')
      stat = res.dig(container_id) unless res.nil?
    
      return nil if stat.nil? || stat.dig('memory_stats').empty?
      memory_usage = calc_memory_size(stat['memory_stats'])
      cpu_usage = calc_cpu_percent(stat['cpu_stats'], stat['precpu_stats'])
      
      # Return format: ['Container Id', 'Datetime', 'Used CPU unit', 'Used Memory size']
      [Time.now.strftime('%s%L').to_i, cpu_usage, memory_usage]
    end

    def run
      logger.info 'Waiting for starting target container.'
      container_conf = Kobanzame::Config.select_conf(config, 'container')
      i = 1
      container_info = ''
      loop do
        containers = describe_target_container
        logger.warn 'Could not get all container information.' if containers.nil?
        container_info = containers['Containers'].find { |c| c['Name'] == container_conf['name'] }
        break if !container_info.nil? && container_info['DockerId'] != ''
        # waiting for 120s
        i += 1
        if i > 5 then
          logger.fatal 'Could not get the information of the batch container.'
          exit 1
        end
        sleep container_conf['check_interval']
      end

      logger.info 'Collecting target container metrics.'
      i = 1
      result = []
      nilbox = []
      until @stop
        metrics = describe_target_container_metrics(container_info.dig('DockerId')) 
        nilbox << nil if metrics.nil?
        break if nilbox.size > 3 # metrics が 3 回取れなかったら, ループを抜ける
        result << metrics unless metrics.nil?
        logger.debug metrics if config[:debug]
        logger.info "Collected #{result.length} metrics..." if i % 10 == 0
        i += 1
        sleep 1
      end
      repo = Kobanzame::Report.new(result)
      Kobanzame::Output.new(config).publish(repo)
      exit 0
    end

    def stop
      @stop = true
    end
  end
end

module Kobanzame
  class Report
    def initialize(result)
      @result = result
    end

    def duration
      times = @result.map { |a| a[0] }
      return '' if times.nil?
      duration = {}
      duration['duration'] = (times[-1] - times[0])
      duration['unit'] = 'ms'
      duration
    end

    def cpu_usage
      cpus = @result.map { |a| a[1] }
      return '' if cpus.nil?
      usage = {}
      usage['average'] = cpus.average
      usage['max'] = cpus.max
      usage['unit'] = '%'
      usage 
    end

    def memory_used
      memories = @result.map { |a| a[2] }
      return '' if memories.nil?
      usage = {}
      usage['average'] = memories.average
      usage['max'] = memories.max
      usage['unit'] = 'MiB'
      usage
    end

    def text(params = nil)
      m = "Memory Used: #{memory_used['average']}MiB(ave)/#{memory_used['max']}MiB(max)"
      c = "CPU Usage: #{cpu_usage['average']}%(ave)/#{cpu_usage['max']}%(max)"
      # task_id = params['task_id']
    
      # "REPORT TaskID:#{task_id} Duration: #{d['duration']}ms, #{memory_used}, #{cpu_usage}"
      "REPORT Duration: #{duration['duration']}ms, #{m}, #{c}"
    end

    def json(params = nil)
      report = {}
      
      report['duration'] = duration
      report['memory_used'] = memory_used
      report['cpu_usage'] = cpu_usage

      res = {}
      res['report'] = report
      res['task_id'] = params['task_id']
      res['docker_name'] = params['docker_name']
      res.to_json
    end
  end
end

module Kobanzame
  class Config
    def self.load_config(opts)
      cfg = read_json(opts[:config])
      se_config = { 
        debug: opts[:debug],
        daemonize: opts[:daemonize],
        pid_path: opts[:pid_file],
        log: opts[:log_file],
        log_level: 'debug',
        kobanzame_config: cfg
      }
      se_config
    end

    def self.read_json(path)
      config_hash = ''
      File.open(path) do |file|
        config_hash = JSON.load(file)
      end
      config_hash
    end

    def self.select_conf(config, key)
      konf = config[:kobanzame_config]
      konf[key]
    end

    def self.select_containers_conf(config)
      konf = config[:kobanzame_config]
      konf['container']
    end

    def self.select_metrics_conf(config)
      konf = config[:kobanzame_config]
      konf['metrics']
    end

    def self.select_outputs_conf(config)
      konf = config[:kobanzame_config]
      konf['outputs']
    end
  end
end

module Kobanzame
  # class Supervisor
  class Collector
    def initialize(opts)
      @opts = opts
    end

    def start
      se = ServerEngine.create(nil, 
                               Kobanzame::Worker,
                               Kobanzame::Config.load_config(@opts))
      se.run
    end
  end
end
