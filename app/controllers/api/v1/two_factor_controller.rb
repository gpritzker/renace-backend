module Api
  module V1
    class TwoFactorController < ActionController::API
      include Auditable
      before_action :authenticate_user!

      # GET /api/v1/two_factor/setup
      def setup
        service = TwoFactorService.new(current_user)
        uri = service.setup
        svg = service.qr_code_svg(uri)
        render json: { qr_svg: svg, uri: uri }
      end

      # POST /api/v1/two_factor/enable
      def enable
        service = TwoFactorService.new(current_user)
        backup_codes = service.enable!(params[:code])

        if backup_codes
          audit('two_factor_enabled', resource: current_user)
          render json: { backup_codes: backup_codes, message: '2FA habilitado exitosamente' }
        else
          render json: { error: 'Código incorrecto' }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/two_factor
      def destroy
        service = TwoFactorService.new(current_user)

        if service.disable!(params[:code])
          audit('two_factor_disabled', resource: current_user)
          render json: { message: '2FA deshabilitado' }
        else
          render json: { error: 'Código incorrecto' }, status: :unprocessable_entity
        end
      end
    end
  end
end
