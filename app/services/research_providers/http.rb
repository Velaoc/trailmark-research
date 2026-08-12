# frozen_string_literal: true

# Real-provider adapter for any OpenAI-compatible chat API (OpenAI, OpenRouter,
# DeepSeek, Groq, together, ...). Activated by setting RESEARCH_PROVIDER_NAME
# to a registered adapter and providing its credentials; see
# config/initializers/research_providers.rb for the registry.
module ResearchProviders
  class Http < Base
    def self.name_key
      "http"
    end

    def self.demo?
      false
    end

    def self.config_surface
      {
        "RESEARCH_PROVIDER_URL" => "OpenAI-compatible /chat/completions endpoint",
        "RESEARCH_PROVIDER_API_KEY" => "API key for that endpoint",
        "RESEARCH_PROVIDER_MODEL" => "model id, e.g. deepseek-chat",
        "RESEARCH_PROVIDER_TEMPERATURE" => "sampling temperature (default 0.2)"
      }
    end

    def initialize(url: nil, api_key: nil, model: nil, temperature: nil)
      @url = url || ENV.fetch("RESEARCH_PROVIDER_URL")
      @api_key = api_key || ENV.fetch("RESEARCH_PROVIDER_API_KEY")
      @model = model || ENV.fetch("RESEARCH_PROVIDER_MODEL")
      @temperature = (temperature || ENV.fetch("RESEARCH_PROVIDER_TEMPERATURE", "0.2")).to_f
    end

    def execute(step, context)
      require "net/http"
      require "json"

      uri = URI(@url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == "https"
      http.open_timeout = 10
      http.read_timeout = 120

      request = Net::HTTP::Post.new(uri)
      request["Authorization"] = "Bearer #{@api_key}"
      request["Content-Type"] = "application/json"
      request.body = JSON.generate(
        model: @model,
        temperature: @temperature,
        messages: [
          { role: "system", content: system_prompt },
          { role: "user", content: user_prompt(step, context) }
        ]
      )

      response = http.request(request)
      unless response.is_a?(Net::HTTPSuccess)
        raise ResearchProviders::ProviderError, "provider returned HTTP #{response.code}: #{response.body.to_s[0, 300]}"
      end

      body = JSON.parse(response.body)
      text = body.dig("choices", 0, "message", "content")
      raise ResearchProviders::ProviderError, "provider response had no message content" if text.nil? || text.empty?

      text.strip
    rescue Net::OpenTimeout, Net::ReadTimeout => e
      raise ResearchProviders::ProviderError, "provider timed out: #{e.class}"
    rescue JSON::ParserError => e
      raise ResearchProviders::ProviderError, "provider returned unparseable JSON: #{e.message}"
    end

    private

    def system_prompt
      <<~PROMPT.strip
        You are Trailmark Research, a careful research agent. You work through a
        research question step by step. For each step you receive the step's
        assignment and the outputs of earlier steps. Answer ONLY what the step
        asks — no preamble, no signposting, no markdown headers unless the step
        asks for structure. Be concrete, cite figures with a year or date where
        you can, and say "unknown" rather than inventing a number.
      PROMPT
    end

    def user_prompt(step, context)
      parts = [ "STEP #{step.position}: #{step.title}" ]
      parts << "\nASSIGNMENT:\n#{step.input}" if step.input.present?
      if context.any?
        parts << "\nEARLIER FINDINGS:"
        context.sort.each do |position, output|
          parts << "--- step #{position} ---\n#{output.to_s[0, 2000]}"
        end
      end
      parts.join("\n")
    end
  end

  class ProviderError < StandardError; end
end
