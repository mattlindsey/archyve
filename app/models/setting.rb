class Setting < ApplicationRecord
  belongs_to :target, optional: true

  class << self
    def get(key, target: nil, default: nil)
      setting = find_by(key:, target_id: target&.id)

      set(key, default, target:) if setting.nil? || setting.value.nil?

      setting&.value || default
    end

    def set(key, value, target: nil)
      find_or_create_by(key:, target_id: target&.id).update!(value:)

      value
    end

    def chat_model
      model_for("chat")
    end

    def embedding_model
      model_for("embedding")
    end

    def summarization_model
      model_for("summarization")
    end

    def entity_extraction_model
      model_for("entity_extraction")
    end

    def model_for(role)
      model_id = find_by(key: "#{role}_model")&.value
      return if model_id.nil?

      ModelConfig.find(model_id)
    end
  end
end
