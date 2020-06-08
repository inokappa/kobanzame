module Kobanzame
  class Utilities
    def self.request(path)
      url = URI.parse(ENV['ECS_CONTAINER_METADATA_URI'] + '/' + path)
      req = Net::HTTP::Get.new(url.path)
      res = Net::HTTP.start(url.host, url.port) {|http|
        http.request(req)
      }
      return nil unless res.code == '200'
      JSON.parse(res.body)
    end
  end
end
