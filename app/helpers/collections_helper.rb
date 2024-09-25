module CollectionsHelper
  def embedding_model_list
    ModelConfig.embedding
  end

  def entity_extraction_model_list
    ModelConfig.generation
  end

  def state_label_for(collection)
    state_text = state_text_for(collection)
    return state_text unless state_text.end_with?("ing")

    if collection.process_step.present? && collection.process_steps.present?
      "#{state_text} (#{collection.process_step}/#{collection.process_steps})"
    else
      state_text
    end
  end

  def state_text_for(collection)
    case collection.state
    when "errored" then "Error"
    else collection.state.capitalize
    end
  end

  def summary_label_for(entity)
    entity.summary_outdated? ? "Summary outdated" : "Up to date"
  end

  def distance_display_value(distance)
    return distance.round if distance > 10

    distance.round(2)
  end
end
