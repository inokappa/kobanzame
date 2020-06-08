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
        begin
          require "kobanzame/outputs/#{mod}"
          eval "Kobanzame::Output::#{mod.camelize}.new(output_conf, @container_conf, @params).publish(result)"
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
      Dir.glob(File.dirname(__FILE__) + '/outputs/*').each do |r|
        modules << File.basename(r, '.rb') unless r.include?('stub')
      end
      modules.sort
    end
  end
end
