class BankAccount < ApplicationRecord
  def self.find_bank_account_by(organization_name:, bic:, iban:)
    self.where(
      organization_name:, bic:, iban:
    ).first
  end
end
