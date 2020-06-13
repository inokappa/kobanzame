require 'time'
require 'aws-sdk-cloudwatch'

module Kobanzame
  module Metric
    class Cloudwatch
      def initialize(metric_conf, params)
        @namespace = metric_conf['namespace']
        @task_id = params['task_id']
      end

      def cw
        @cw ||= Aws::CloudWatch::Client.new
      end

      def publish(result)
        data = write_metric_data(result)
        begin
          cw.put_metric_data(data)
        rescue Aws::CloudWatch::Errors::ServiceError
          raise $!.message
        end
      end

      private

      # Input Data: [[timestamp, CPU Usage, Memory Used], [1591710550364, 0.0, 0.621], [1591710553452, 0.0, 0.621]]       
      def write_metric_data(datas)
        metric = {}
        metric_datas = []
        metric[:namespace] = @namespace
        datas.each do |data|
          metric_data = [
            {
              metric_name: 'CPU Usage',
              dimensions: dimentions,
              timestamp: timestamp(data[0]),
              value: data[1],
              unit: 'Percent'
            },
            {
              metric_name: 'Memory Used',
              dimensions: dimentions,
              timestamp: timestamp(data[0]),
              value: data[2],
              unit: 'Megabits'
            }
          ]
          metric_datas << metric_data
        end
        metric[:metric_data] = metric_datas.flatten
        metric
      end

      def dimentions
        dims = [
          {
            name: 'TaskId',
            value: @task_id,
          }
        ]
        dims
      end

      def timestamp(t)
        DateTime.strptime((t.to_i/1000).to_s, '%s').iso8601
      end
    end
  end
end
