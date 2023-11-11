require "rails_helper"

RSpec.describe CreateBulkTransfers do
  context "when creating bulk transfers" do
    context "when the bank account is not found" do
      it "raises BankAccountNotFoundError" do
        bank_account_repository = class_double(BankAccount)
        first_credit_transfer_command = instance_double(
          CreditTransferCommand,
          amount_cents: 1450,
          counterparty_name: "Bip Bip",
          counterparty_bic: "CRLYFRPPTOU",
          counterparty_iban: "EE383680981021245685",
          description: "Wonderland/4410"
        )
        second_credit_transfer_command = instance_double(
          CreditTransferCommand,
          amount_cents: 6123800,
          counterparty_name: "Wile E Coyote",
          counterparty_bic: "ZDRPLBQI",
          counterparty_iban: "DE9935420810036209081725212",
          description: "//TeslaMotors/Invoice/12"
        )
        create_transfer_command = double(
          :create_transfer_command,
          organization_name: "ACME Corp",
          bic: "OIVUSCLQXXX",
          iban: "FR10474608000002006107XXXXX",
          credit_transfers: [
            first_credit_transfer_command,
            second_credit_transfer_command
          ]
        )
        allow(bank_account_repository).to receive(:transaction).and_yield
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
        first_credit_transfer_command = instance_double(
          CreditTransferCommand,
          amount_cents: 1450,
          counterparty_name: "Bip Bip",
          counterparty_bic: "CRLYFRPPTOU",
          counterparty_iban: "EE383680981021245685",
          description: "Wonderland/4410"
        )
        second_credit_transfer_command = instance_double(
          CreditTransferCommand,
          amount_cents: 6123800,
          counterparty_name: "Wile E Coyote",
          counterparty_bic: "ZDRPLBQI",
          counterparty_iban: "DE9935420810036209081725212",
          description: "//TeslaMotors/Invoice/12"
        )
        create_transfer_command = double(
          :create_transfer_command,
          organization_name: "ACME Corp",
          bic: "OIVUSCLQXXX",
          iban: "FR10474608000002006107XXXXX",
          transaction_total_amount_cents: 6125250,
          credit_transfers: [
            first_credit_transfer_command,
            second_credit_transfer_command
          ]
        )
        allow(bank_account_repository).to receive(:transaction).and_yield
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
      it "creates transfers" do
        bank_account_repository = class_double(BankAccount)
        bank_account = instance_double(BankAccount, id: 1)
        transfer_repository = class_spy(Transfer)
        first_credit_transfer_command = instance_double(
          CreditTransferCommand,
          amount_cents: 1450,
          counterparty_name: "Bip Bip",
          counterparty_bic: "CRLYFRPPTOU",
          counterparty_iban: "EE383680981021245685",
          description: "Wonderland/4410"
        )
        second_credit_transfer_command = instance_double(
          CreditTransferCommand,
          amount_cents: 6123800,
          counterparty_name: "Wile E Coyote",
          counterparty_bic: "ZDRPLBQI",
          counterparty_iban: "DE9935420810036209081725212",
          description: "//TeslaMotors/Invoice/12"
        )
        create_transfer_command = double(
          :create_transfer_command,
          organization_name: "ACME Corp",
          bic: "OIVUSCLQXXX",
          iban: "FR10474608000002006107XXXXX",
          transaction_total_amount_cents: 6125250,
          credit_transfers: [
            first_credit_transfer_command,
            second_credit_transfer_command
          ]
        )
        allow(bank_account_repository).to receive(:transaction).and_yield
        allow(bank_account_repository).to receive(:find_bank_account_by)
          .with(
            organization_name: create_transfer_command.organization_name,
            bic: create_transfer_command.bic,
            iban: create_transfer_command.iban,
          ).and_return(bank_account)
        allow(bank_account).to receive(:sufficient_balance_for_transaction?)
          .with(6125250).and_return(true)

        described_class.new(
          create_transfer_command,
          bank_account_repository:,
          transfer_repository:
        ).create

        expect(transfer_repository).to have_received(:create)
          .with(
            counterparty_name: first_credit_transfer_command.counterparty_name,
            counterparty_iban: first_credit_transfer_command.counterparty_iban,
            counterparty_bic: first_credit_transfer_command.counterparty_bic,
            amount_cents: first_credit_transfer_command.amount_cents,
            bank_account_id: bank_account.id,
            description: first_credit_transfer_command.description
          )
        expect(transfer_repository).to have_received(:create)
          .with(
            counterparty_name: second_credit_transfer_command.counterparty_name,
            counterparty_iban: second_credit_transfer_command.counterparty_iban,
            counterparty_bic: second_credit_transfer_command.counterparty_bic,
            amount_cents: second_credit_transfer_command.amount_cents,
            bank_account_id: bank_account.id,
            description: second_credit_transfer_command.description
          )
      end
    end
  end
end
