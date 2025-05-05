class ApplicationSerializer < ActiveModel::Serializer
    private
  
    def default_host
      Rails.application.routes.default_url_options[:host] || ENV['APP_HOST'] || 'http://localhost:3000'
    end
  end
  