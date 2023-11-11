class BankAccount < ApplicationRecord
  def self.find_bank_account_by(organization_name:, bic:, iban:)
    self.where(
      organization_name:, bic:, iban:
    ).first
  end

  def sufficient_balance_for_transaction?(amount_in_cents)
    balance_cents >= amount_in_cents
  end
end
