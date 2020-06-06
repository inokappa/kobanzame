require 'aws-sdk-cloudwatchlogs'

module Kobanzame
  module Outputs
    class CloudWatchLogs
      def initialize(params)
        @log_group_name = params['log_group_name']
        @log_stream_prefix = params['log_stream_name_prefix']
        @container_name = params['container_name']
        @task_id = params['task_id']
      end

      def cwlog
        @cwlog ||= Aws::CloudWatchLogs::Client.new
      end

      def log_stream_name
        return @task_id if @log_stream_prefix.nil?
        @log_stream_prefix + '/' + @container_name + '/' + @task_id
      end

      def upload_sequence_token
        begin
          cwlog.describe_log_streams({
            log_group_name: @log_group_name,
            log_stream_name_prefix: log_stream_name
          })['log_streams'][0]['upload_sequence_token']
        rescue Aws::CloudWatchLogs::ServiceError => ex
          raise $!.message
        end
      end

      def publish(result)
        event = {
          log_group_name: @log_group_name,
          log_stream_name: log_stream_name,
          log_events: [{
            timestamp: (Time.now.utc.to_f.round(3) * 1000).to_i,
            message: result
          }],
          sequence_token: upload_sequence_token
        }
        begin
          cwlog.put_log_events(event)
        rescue Aws::CloudWatchLogs::ServiceError
          raise $!.message
        end
      end
    end
  end
end
