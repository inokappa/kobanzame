module Kobanzame
  module Output
    class Stdout < Outputs
      def initialize(output_conf, container_conf, params)
        @format = container_conf['report_format']
      end

      def publish(result)
        $stdout.puts result.send(@format)
      end
    end
  end
end
