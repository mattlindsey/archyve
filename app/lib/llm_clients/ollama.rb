require_relative "common"

module LlmClients
  class Ollama < Client
    # rubocop:disable all
    def complete(prompt, &block)
      @stats = new_stats
      request = completion_request(prompt)

      Net::HTTP.start(@uri.hostname, @uri.port, use_ssl: @uri.scheme == "https") do |http|
        http.request(request) do |response|
          raise response_error_for(response) unless response.code.to_i >= 200 && response.code.to_i < 300

          stats[:start_time] = Process.clock_gettime(Process::CLOCK_MONOTONIC)

          current_chunk = ""
          current_batch = ""
          current_batch_size = 0

          response.read_body do |chunk|
            current_chunk << chunk
            next unless current_chunk.ends_with?("\n") || current_chunk.ends_with?("}")

            message = extract_message(current_chunk)
            current_batch << message
            current_chunk = ""
            stats[:tokens] += 1
            current_batch_size += 1

            if current_batch_size == @batch_size
              Rails.logger.debug "==> #{current_batch}"
              yield current_batch

              current_batch_size = 0
              current_batch = ""
            end
          end

          if current_batch_size > 0
            Rails.logger.debug "==> #{current_batch}"
            yield current_batch
          end

          calculate_stats
        end
      end
    end
    # rubocop:enable all

    def embed(model, prompt)
      request = embedding_request(prompt)
      http = Net::HTTP.new(@uri.hostname, @uri.port, use_ssl: @uri.scheme == "https")

      http.request(request)
    end

    private

    def completion_request(prompt)
      request = Net::HTTP::Post.new(uri(completion_path), **headers)
      request.body = {
        model: @model,
        prompt:,
        temperature: @temperature,
        stream: true,
        max_tokens: 200
      }.to_json

      request
    end

    def embedding_request(prompt)
      Net::HTTP::Post.new(uri(embedding__path), **headers)
      request.body = {
        model: embedding_model,
        prompt:
      }.to_json
    end

    def extract_message(response_string)
      response_hash = JSON.parse(response_string)
      message = response_hash["response"]
      Rails.logger.debug("<== '#{message}'")

      message
    end

    def template_for(model)
      MODEL_TEMPLATE_MAP.each do |name, template|
        if model =~ Regexp.new(name)
          return template
        end
      end

      { prefix: "", suffix: "" }
    end

    def completion_path
      "/api/generate"
    end

    def embedding_path
      "/api/embeddings"
    end

    def embedding_model
      # TODO: make this configurable
      "all-minilm"
    end
  end
end
