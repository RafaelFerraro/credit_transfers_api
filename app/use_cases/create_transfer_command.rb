class CreateTransferCommand
  attr_reader :organization_name, :bic, :iban

  def initialize(raw_params)
    @raw_params = raw_params
    @organization_name = raw_params["organization_name"]
    @bic = raw_params["bic"]
    @iban = raw_params["iban"]
    @transfers = raw_params["credit_transfers"]
  end

  def credit_transfers
    @transfers.map { |transfer_params| CreditTransferCommand.new(transfer_params)}
  end

  def transaction_total_amount_cents
    credit_transfers.map(&:amount_cents).sum
  end
end
