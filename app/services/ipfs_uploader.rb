# app/services/ipfs_uploader.rb

require 'httparty'

class IpfsUploader
  include HTTParty
  base_uri 'https://api.web3.storage'

  def initialize(file:, filename:)
    @file = file
    @filename = filename
  end

  def upload
    response = self.class.post(
      '/upload',
      headers: {
        "Authorization" => "Bearer #{ENV['WEB3_STORAGE_TOKEN']}",
        "Content-Type" => "application/octet-stream"
      },
      body: File.read(@file)
    )

    if response.success?
      JSON.parse(response.body)["cid"]
    else
      raise "IPFS upload failed: #{response.body}"
    end
  end
end