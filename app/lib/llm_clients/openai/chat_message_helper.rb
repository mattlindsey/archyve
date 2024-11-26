module LlmClients
  module Openai
    class ChatMessageHelper
      def initialize(message)
        @message = message
      end

      def chat_history
        @chat_history ||= generate_chat_history
      end

      private

      def generate_chat_history
        # use message content only for all messages but the last
        chat_messages = messages[..-2].map do |message|
          {
            role: role_for_message(message),
            content: message.raw_content || message.content,
          }
        end

        # use the augmented prompt for the last message, if set
        last_message = messages[-1]
        chat_messages << {
          role: role_for_message(last_message),
          content: last_message.prompt || last_message.content || last_message.raw_content,
        }
      end

      def role_for_message(message)
        return "system" if message.author.nil?

        message.author.is_a?(User) ? "user" : "assistant"
      end

      def messages
        @messages ||= @message.previous(num_messages_to_include) + [@message]
      end

      def num_messages_to_include
        Setting.get(:num_messages_to_include_in_context, default: 20)
      end
    end
  end
end
