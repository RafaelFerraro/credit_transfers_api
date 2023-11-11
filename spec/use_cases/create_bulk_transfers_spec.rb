require "rails_helper"

RSpec.describe CreateBulkTransfers do
  context "when creating bulk transfers" do
    context "when the bank account is not found" do
      it "raises BankAccountNotFoundError" do
        bank_account_repository = class_double(BankAccount)
        create_transfer_command = double(
          :create_transfer_command,
          organization_name: "ACME Corp",
          bic: "OIVUSCLQXXX",
          iban: "FR10474608000002006107XXXXX",
          credit_transfers: [
            OpenStruct.new(
              amount: "14.5",
              counterparty_name: "Bip Bip",
              counterparty_bic: "CRLYFRPPTOU",
              counterparty_iban: "EE383680981021245685",
              description: "Wonderland/4410"
            ),
            OpenStruct.new(
              amount: "61238",
              counterparty_name: "Wile E Coyote",
              counterparty_bic: "ZDRPLBQI",
              counterparty_iban: "DE9935420810036209081725212",
              description: "//TeslaMotors/Invoice/12"
            )
          ]
        )
        allow(bank_account_repository).to receive(:find_bank_account_by)
          .with(
            organization_name: create_transfer_command.organization_name,
            bic: create_transfer_command.bic,
            iban: create_transfer_command.iban,
          ).and_return(nil)

        expect {
          described_class.new(
            create_transfer_command,
            bank_account_repository:
          ).create
        }.to raise_error(BankAccountNotFoundError)
      end
    end

    context "when there isn't enough balance to proccess the transfers" do
      it "raises InsufficientBalanceError" do
        bank_account_repository = class_double(BankAccount)
        bank_account = instance_double(BankAccount)
        create_transfer_command = double(
          :create_transfer_command,
          organization_name: "ACME Corp",
          bic: "OIVUSCLQXXX",
          iban: "FR10474608000002006107XXXXX",
          credit_transfers: [
            OpenStruct.new(
              amount: "14.5",
              counterparty_name: "Bip Bip",
              counterparty_bic: "CRLYFRPPTOU",
              counterparty_iban: "EE383680981021245685",
              description: "Wonderland/4410"
            ),
            OpenStruct.new(
              amount: "61238",
              counterparty_name: "Wile E Coyote",
              counterparty_bic: "ZDRPLBQI",
              counterparty_iban: "DE9935420810036209081725212",
              description: "//TeslaMotors/Invoice/12"
            )
          ]
        )
        allow(bank_account_repository).to receive(:find_bank_account_by)
          .with(
            organization_name: create_transfer_command.organization_name,
            bic: create_transfer_command.bic,
            iban: create_transfer_command.iban,
          ).and_return(bank_account)
        allow(bank_account).to receive(:sufficient_balance_for_transaction?)
          .with(6125250).and_return(false)

        expect {
          described_class.new(
            create_transfer_command,
            bank_account_repository:
          ).create
        }.to raise_error(InsufficientBalanceError)
      end
    end

    context "when everything is correct" do
      it "creates transfers"
      it "updates bank account balance"
    end
  end
end
