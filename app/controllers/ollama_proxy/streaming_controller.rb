module OllamaProxy
  class StreamingController < OllamaProxyController
    include ActionController::Live

    before_action :set_content_type_header

    def get
      http_response = @handler.handle do |chunk|
        response.stream.write chunk
      end

      if @proxy.yielded
        response.stream.close
      else
        render json: http_response.body, headers: http_response.to_hash, status: @proxy.code
      end
    end

    def post
      http_response = @handler.handle do |chunk|
        response.stream.write chunk
      end

      if @proxy.yielded
        response.stream.close
      else
        render json: http_response, status: @proxy.code
      end
    end

    protected

    def set_content_type_header
      response.headers['Content-Type'] = 'application/json'
    end
  end
end
