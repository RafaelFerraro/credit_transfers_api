class BankAccount < ApplicationRecord
  def self.find_bank_account_by(organization_name:, bic:, iban:)
    self.where(
      organization_name:, bic:, iban:
    ).first
  end

  def withdraw_money_from_account!(amount_cents)
    raise InsufficientBalanceError unless sufficient_balance_for_transaction?(amount_cents)

    update(balance_cents: balance_cents - amount_cents)
  end

  private

  def sufficient_balance_for_transaction?(amount_cents)
    balance_cents >= amount_cents
  end
end
