module V1
  class EntitiesController < ApiController
    include Pageable

    before_action :set_collection!
    before_action :set_entity!, only: [:show]

    def index
      @pagy, @entities = pagy(@collection.graph_entities, items:, page:)

      render json: { entities: @entities.map { |e| body_for(e) }, page: page_data }
    end

    def show
      render json: body_for(@entity)
    end

    private

    def body_for(entity)
      body = entity.attributes.to_h.slice(*render_attributes)
      remove_id_suffix_from("collection", body)

      body
    end

    def set_entity!
      @entity = GraphEntity.find(params[:id])

      render json: { error: "Entity not found" }, status: :not_found if @entity.nil?
    end

    def set_collection!
      @collection = Collection.find_by(id: params[:collection_id])

      render json: { error: "Collection not found" }, status: :not_found if @collection.nil?
    end

    def render_attributes
      %w[id name entity_type collection_id summary summary_outdated vector_id created_at updated_at]
    end
  end
end
