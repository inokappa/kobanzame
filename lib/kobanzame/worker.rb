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

    def load_container_config
      Kobanzame::Config.select_conf(config, 'container')
    end

    def describe_container_info
      cf = load_container_config
      logger.info 'Waiting for starting target container.'
      i = 1
      container_info = ''
      loop do
        containers = describe_target_container
        logger.warn 'Could not get all container information.' if containers.nil?
        container_info = containers['Containers'].find { |c| c['Name'] == cf['name'] }
        break if !container_info.nil? && container_info['DockerId'] != ''
        # waiting for 120s
        i += 1
        if i > 5 then
          logger.fatal 'Could not get the information of the batch container.'
          exit 1
        end
        sleep cf['check_interval'].to_i
      end
      container_info
    end

    def run
      cf = load_container_config
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
        sleep cf['check_interval'].to_i
      end
      params = Kobanzame::Config.generate_task_params(container_info)
      repo = Kobanzame::Report.new(result, params)
      Kobanzame::Outputs.new(config, params).publish(repo)
      exit 0
    end

    def stop
      @stop = true
    end
  end
end
