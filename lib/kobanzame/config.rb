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

    def self.generate_task_params(container_info)
      params = {}
      params['task_id'] = (0...32).map{ (65 + rand(26)).chr }.join
      if container_info.dig('Labels', 'com.amazonaws.ecs.task-arn')
        params['task_id'] = container_info.dig('Labels', 'com.amazonaws.ecs.task-arn').split('/')[-1]
      end
      params['docker_id'] = container_info.dig('DockerId')
      params['docker_name'] = container_info.dig('DockerName')
      params
    end
  end
end
