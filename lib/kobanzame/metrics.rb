module Kobanzame
  class Metrics
    def initialize(conf, params)
      @metrics_conf = Kobanzame::Config.select_conf(conf, 'metrics') 
      @params = params
      @conf = conf
    end

    def logger
      @logger ||= ServerEngine::DaemonLogger.new(@conf[:log] || STDOUT, @conf)
    end

    def publish(result)
      load_output_modules.each do |mod|
        begin
          require "kobanzame/metrics/#{mod}"
          class_name = "Kobanzame::Metric::#{mod.camelize}"
          Object.const_get(class_name).new(@metrics_conf, @params).publish(result)
          logger.info("Sent information to #{mod}")
        rescue LoadError => ex
          puts ex
          logger.warn("Could not load #{mod} module.")
        rescue => ex
          puts ex
          logger.warn("Could not send information to #{mod}.")
        end
      end
    end

    private

    def load_output_modules
      modules = []
      Dir.glob(File.dirname(__FILE__) + '/metrics/*').each do |r|
        modules << File.basename(r, '.rb') unless r.include?('stub')
      end
      modules.sort
    end
  end
end
