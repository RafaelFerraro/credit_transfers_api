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

  context "when withdrawing money from account" do
    context "when there is enough money in the account" do
      it "updates the account balance" do
        bank_account = described_class.new(balance_cents: 1000)

        response = bank_account.withdraw_money_from_account!(200)

        expect(bank_account.reload.balance_cents).to eq(800)
      end
    end

    context "when there isn't enough money in the account" do
      it "raises an InsufficientBalanceError" do
        bank_account = described_class.new(balance_cents: 1000)

        expect {
          bank_account.withdraw_money_from_account!(2000)
        }.to raise_error(InsufficientBalanceError)
      end
    end
  end
end
