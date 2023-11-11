class CreateBulkTransfers
  def initialize(create_transfer_command, overrides = {})
    @create_transfer_command = create_transfer_command
    @bank_account_repository = overrides.fetch(:bank_account_repository) do
      BankAccount
    end
    @transfer_repository = overrides.fetch(:transfer_repository) do
      Transfer
    end
  end

  def create
    @bank_account_repository.transaction do
      bank_account.withdraw_money_from_account!(
        @create_transfer_command.transaction_total_amount_cents
      )

      @create_transfer_command.credit_transfers.each do |credit_transfer|
        @transfer_repository.create(
          counterparty_name: credit_transfer.counterparty_name,
          counterparty_iban: credit_transfer.counterparty_iban,
          counterparty_bic: credit_transfer.counterparty_bic,
          amount_cents: credit_transfer.amount_cents,
          bank_account_id: bank_account.id,
          description: credit_transfer.description
        )
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
end
