class CreateBulkTransfers
  def initialize(create_transfer_command, overrides = {})
    @create_transfer_command = create_transfer_command
    @bank_account_repository = overrides.fetch(:bank_account_repository) do
      BankAccount
    end
    @create_transfer_use_case = overrides.fetch(:create_transfer_use_case) do
      CreateTransfer.new
    end
  end

  def create
    @bank_account_repository.transaction do
      raise InsufficientBalanceError unless bank_account.sufficient_balance_for_transaction?(transaction_total_amount_cents)

      @create_transfer_command.credit_transfers.each do |credit_transfer|
        @create_transfer_use_case.create(credit_transfer)
      end
    end
  end

  private

  def bank_account
    @bank_account ||= @bank_account_repository.find_bank_account_by(
      organization_name: @create_transfer_command.organization_name,
      bic: @create_transfer_command.bic,
      iban: @create_transfer_command.iban
    ).tap do |account|
      raise BankAccountNotFoundError unless account
    end
  end

  def transaction_total_amount_cents
    @create_transfer_command.credit_transfers.map do |credit_transfer|
      (BigDecimal(credit_transfer.amount.to_s) * 100).to_i
    end.sum
  end
end
