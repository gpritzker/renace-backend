# app/services/blockchain_service.rb

require 'eth'

class BlockchainService
  def initialize(cid)
    @cid = cid
    @client = Eth::Client.create ENV["BLOCKCHAIN_PROVIDER_URL"]
    @key = Eth::Key.new priv: ENV["BLOCKCHAIN_PRIVATE_KEY"]
    @contract_address = ENV["BLOCKCHAIN_CONTRACT_ADDRESS"]
  end

  def register_remember_hash
    abi = [
      {
        "inputs": [{ "name": "_cid", "type": "string" }],
        "name": "storeCID",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
      }
    ]

    contract = Eth::Contract.from_abi(name: "RenaceContract", address: @contract_address, abi: abi)

    data = contract.transact.storeCID(@cid)
    tx = Eth::Tx.new({
      data: data,
      gas_limit: 150_000,
      gas_price: @client.gas_price,
      nonce: @client.get_nonce(@key.address),
      to: @contract_address
    })

    tx.sign @key
    tx_hash = @client.send_raw_transaction(tx.hex)
    tx_hash
  end
end