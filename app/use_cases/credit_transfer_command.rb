class CreditTransferCommand
  attr_reader :amount, :counterparty_bic, :counterparty_iban,
    :counterparty_name, :description

  def initialize(transfer_params)
    @amount = transfer_params["amount"].to_s
    @counterparty_name = transfer_params["counterparty_name"]
    @counterparty_bic = transfer_params["counterparty_bic"]
    @counterparty_iban = transfer_params["counterparty_iban"]
    @description = transfer_params["description"]
  end

  def amount_cents
    (BigDecimal(@amount) * 100).to_i
  end
end
