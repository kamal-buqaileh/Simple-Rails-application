# app/controllers/api/v1/partners_controller.rb
module Api
  module V1
    class PartnersController < ApplicationController
      # GET /api/v1/partners
      def index
        filters = partner_search_params
        service = MatchPartnersService.new(
          latitude: filters[:lat],
          longitude: filters[:lng],
          service_id: filters[:service_id],
          material_id: filters[:material_id],
          last_id: filters.fetch(:last_id, 0),
          limit: filters.fetch(:limit, 10)
        )
        partners = service.call

        # Serialize the partners and compute the ETag from the serialized JSON.
        serialized_data = PartnerSerializers::MatchSerializer.new(partners).serializable_hash.to_json
        etag_value = Digest::MD5.hexdigest(serialized_data)

        if stale?(etag: etag_value)
          render json: serialized_data, status: :ok
        end
      end

      # GET /api/v1/partners/:id
      def show
        service = FetchPartnerDetailsService.new(params[:id])
        partner = service.call
        if partner
          serialized_data = PartnerSerializers::DetailSerializer.new(partner, { include: [ :services, :materials ] }).serializable_hash.to_json
          etag_value = Digest::MD5.hexdigest(serialized_data)

          if stale?(etag: etag_value)
            render json: serialized_data, status: :ok
          end
        else
          render json: { error: "Partner not found" }, status: :not_found
        end
      end

      private

      def partner_search_params
        params.permit(:lat, :lng, :service_id, :material_id, :last_id, :limit)
      end
    end
  end
end
