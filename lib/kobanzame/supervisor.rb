module Kobanzame
  class Supervisor
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
