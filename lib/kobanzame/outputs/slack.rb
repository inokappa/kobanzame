require 'json'
require 'net/http'

module Kobanzame
  module Output
    class Slack
      def initialize(output_conf, container_conf, params)
        # @container_name = container_conf['name']
        # @format = container_conf['report_format']
        # @task_id = params['task_id']
        @output_conf = output_conf
      end

      def publish(result)
        attachements = result.send(@format)
        params = build_params(attachements)
        send(params)
      end

      private

      def build_attachements(result)
        attachments = [
          {
            'fallback': '',
            'title': @output_conf['title'],
            'fields': [
              {
                'title': 'Output',
                'value': event['detail']['taskArn'],
                'short': false
              },
            ]
          }
        ]
        attachments
      end

      def build_params(attachments)
        params = {
          username: @output_conf['user_name'],
          icon_emoji: @output_conf['icon_emoji'] ,
          text: '',
          attachments: attachments
        }
        params
      end

      def send(build_params)
        uri = URI.parse(ENV['SLACK_WEBHOOK_URL'])
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        begin
          http.start do
            request = Net::HTTP::Post.new(uri.path)
            request.set_form_data(payload: build_params.to_json)
            http.request(request)
          end
        rescue => e
          puts 'Slack send failure: ' + e.message
        end
        puts 'ok'
      end
    end
  end
end
