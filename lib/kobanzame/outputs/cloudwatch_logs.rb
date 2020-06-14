require 'aws-sdk-cloudwatchlogs'

module Kobanzame
  module Output
    class CloudwatchLogs
      def initialize(output_conf, container_conf, params)
        @log_group_name = output_conf['log_group_name']
        @log_stream_prefix = output_conf['log_stream_prefix']
        @log_stream_name = output_conf['log_stream_name']
        @container_name = container_conf['name']
        @format = container_conf['report_format']
        @task_id = params['task_id']
      end

      def cwlog
        @cwlog ||= Aws::CloudWatchLogs::Client.new
      end

      def publish(result)
        event = {
          log_group_name: @log_group_name,
          log_stream_name: log_stream_name,
          log_events: [{
            timestamp: (Time.now.utc.to_f.round(3) * 1000).to_i,
            message: result.send(@format)
          }]
        }
        event['sequence_token'] = upload_sequence_token if upload_sequence_token != ''
        begin
          cwlog.put_log_events(event)
        rescue Aws::CloudWatchLogs::Errors::ServiceError
          raise $!.message
        end
      end

      private

      def log_stream_name
        return @task_id if @log_stream_prefix.nil? && @log_group_name.nil?
        return @log_group_name if @log_stream_prefix.nil?
        @log_stream_prefix + '/' + @container_name + '/' + @task_id
      end

      def upload_sequence_token
        return '' if log_streams.empty?
        log_streams[0]['upload_sequence_token']
      end

      def log_streams
        begin
          res = cwlog.describe_log_streams({
            log_group_name: @log_group_name,
            log_stream_name_prefix: log_stream_name
          })
        rescue Aws::CloudWatchLogs::Errors::ServiceError
          raise $!.message
        end

        begin
          cwlog.create_log_stream({
            log_group_name: @log_group_name,
            log_stream_name: log_stream_name
          })
          return []
        rescue Aws::CloudWatchLogs::Errors::ServiceError
          raise $!.message
        end if res['log_streams'].empty?
        res['log_streams']
      end
    end
  end
end
