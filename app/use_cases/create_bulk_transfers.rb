class CreateBulkTransfers
  def initialize(overrides = {})
    @bank_account_repository = overrides.fetch(:bank_account_repository) do
      BankAccount
    end
  end

  def create(create_transfer_command)
    @bank_account_repository.find_bank_account_by(
      organization_name: create_transfer_command.organization_name,
      bic: create_transfer_command.bic,
      iban: create_transfer_command.iban
    ).tap do |account|
      raise BankAccountNotFoundError unless account
    end
  end

  private

  def bank_account
  end
end
