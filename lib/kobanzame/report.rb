module Kobanzame
  class Report
    def initialize(result, params)
      @result = result
      @params = params
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

    def text
      m = "Memory Used: #{memory_used['average']}MiB(ave)/#{memory_used['max']}MiB(max)"
      c = "CPU Usage: #{cpu_usage['average']}%(ave)/#{cpu_usage['max']}%(max)"
      task_id = @params['task_id']
    
      "REPORT TaskID:#{task_id} Duration: #{duration['duration']}ms, #{m}, #{c}"
    end

    def json
      report = {}
      
      report['duration'] = duration
      report['memory_used'] = memory_used
      report['cpu_usage'] = cpu_usage

      res = {}
      res['report'] = report
      res['task_id'] = @params['task_id']
      res['docker_name'] = @params['docker_name']
      res.to_json
    end
  end
end
