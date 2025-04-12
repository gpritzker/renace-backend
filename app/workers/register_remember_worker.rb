# app/workers/register_remember_worker.rb

class RegisterRememberWorker
    include Sidekiq::Worker
  
    def perform(file_path, filename)
      uploader = IpfsUploader.new(file: file_path, filename: filename)
      cid = uploader.upload
  
      BlockchainService.new(cid).register_remember_hash
    end
end  