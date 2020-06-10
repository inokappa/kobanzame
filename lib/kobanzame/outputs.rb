module Kobanzame
  class Outputs 
    def initialize(conf, params)
      @outputs_conf = Kobanzame::Config.select_conf(conf, 'outputs') 
      @container_conf = Kobanzame::Config.select_conf(conf, 'container') 
      @params = params
      @conf = conf
    end

    def logger
      @logger ||= ServerEngine::DaemonLogger.new(@conf[:log] || STDOUT, @conf)
    end

    def publish(result)
      load_output_modules.each do |mod|
        output_conf = @outputs_conf.select { |c| c['name'] == mod }.last
        if output_conf.nil?
          logger.warn("Skip output to #{mod}")
          next
        end
        begin
          require "kobanzame/outputs/#{mod}"
          class_name = "Kobanzame::Output::#{mod.camelize}"
          Object.const_get(class_name).new(output_conf, @container_conf, @params).publish(result)
          logger.info("Sent information to #{mod}")
        rescue LoadError
          logger.warn("Could not load #{mod} module.")
        rescue
          logger.warn("Could not send information to #{mod}.")
        end
      end
    end

    private

    def load_output_modules
      modules = []
      Dir.glob(File.dirname(__FILE__) + '/outputs/*').each do |r|
        modules << File.basename(r, '.rb') unless r.include?('stub')
      end
      modules.sort
    end
  end
end
