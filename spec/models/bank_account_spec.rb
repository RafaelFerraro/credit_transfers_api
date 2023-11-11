require "rails_helper"

RSpec.describe BankAccount do
  context "when finding bank account by name, bic and iban" do
    context "when the name does not exist" do
      it "returns nil" do
        organization_name = "Org Name"
        bic = "Org Bic"
        iban = "Org Iban"

        bank_account = described_class.create(
          organization_name:,
          bic:,
          iban:
        )

        expect(
          described_class.find_bank_account_by(
            organization_name: "Whatever",
            bic:,
            iban:
          )
        ).to be_nil
      end
    end

    context "when the bic does not exist" do
      it "returns nil" do
        organization_name = "Org Name"
        bic = "Org Bic"
        iban = "Org Iban"

        bank_account = described_class.create(
          organization_name:,
          bic:,
          iban:
        )

        expect(
          described_class.find_bank_account_by(
            organization_name:,
            bic: "Whatever",
            iban:
          )
        ).to be_nil
      end
    end

    context "when the iban does not exist" do
      it "returns nil" do
        organization_name = "Org Name"
        bic = "Org Bic"
        iban = "Org Iban"

        bank_account = described_class.create(
          organization_name:,
          bic:,
          iban:
        )

        expect(
          described_class.find_bank_account_by(
            organization_name:,
            bic:,
            iban: "Whatever"
          )
        ).to be_nil
      end
    end

    context "when everything is ok" do
      it "returns the proper bank account" do
        organization_name = "Org Name"
        bic = "Org Bic"
        iban = "Org Iban"

        bank_account = described_class.create(
          organization_name:,
          bic:,
          iban:,
        )

        expect(
          described_class.find_bank_account_by(
            organization_name:,
            bic:,
            iban:
          )
        ).to eq(bank_account)
      end
    end
  end

  context "when asking for sufficient balance for a transaction" do
    it "returns true if there is sufficient balance" do
      bank_account = described_class.new(balance_cents: 2000)

      response = bank_account.sufficient_balance_for_transaction?(1000)

      expect(response).to be_truthy
    end

    it "returns false if there isn't sufficient balance" do
      bank_account = described_class.new(balance_cents: 1000)

      response = bank_account.sufficient_balance_for_transaction?(2000)

      expect(response).to be_falsey
    end
  end
end
