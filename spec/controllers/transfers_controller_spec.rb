require 'rails_helper'

RSpec.describe "Transfers", type: :request do
  describe "POST /transfers" do
    context "when there isn't enough balance in the customer's account" do
      let(:bank_account) do
        BankAccount.create(
          organization_name: "Org Name",
          iban: "Iban",
          bic: "Bic",
          balance_cents: 10000,
        )
      end
      let(:request_body) {
        {
          "organization_name" => bank_account.organization_name,
          "organization_bic" => bank_account.bic,
          "organization_iban" => bank_account.iban,
          "credit_transfers" => [
            {
              "amount" => "14.5",
              "counterparty_name" => "Bip Bip",
              "counterparty_bic" => "CRLYFRPPTOU",
              "counterparty_iban" => "EE383680981021245685",
              "description" => "Wonderland/4410"
            },
            {
              "amount" => "61238",
              "counterparty_name" => "Wile E Coyote",
              "counterparty_bic" => "ZDRPLBQI",
              "counterparty_iban" => "DE9935420810036209081725212",
              "description" => "//TeslaMotors/Invoice/12"
            },
            {
              "amount" => "999",
              "counterparty_name" => "Bugs Bunny",
              "counterparty_bic" => "RNJZNTMC",
              "counterparty_iban" => "FR0010009380540930414023042",
              "description" => "2020 09 24/2020 09 25/GoldenCarrot/"
            }
          ]
        }
      }
      it "returns a 422 http status code" do
        post "/transfers", :params => request_body

        expect(response.status).to eq(422)
      end

      it "does not add any transfer" do
        post "/transfers", :params => request_body

        expect(Transfer.count).to eq(0)
      end

      it "does not change the customer's account balance" do
        post "/transfers", :params => request_body

        balance = BankAccount.find(bank_account.id).balance_cents

        expect(balance).to eq(bank_account.balance_cents)
      end
    end

    context "when there is enough balance in the customer's account" do
      let(:bank_account) do
        BankAccount.create(
          organization_name: "Org Name",
          iban: "Iban",
          bic: "Bic",
          balance_cents: 100000000,
        )
      end
      let(:request_body) {
        {
          "organization_name" => bank_account.organization_name,
          "organization_bic" => bank_account.bic,
          "organization_iban" => bank_account.iban,
          "credit_transfers" => [
            {
              "amount" => "14.5",
              "counterparty_name" => "Bip Bip",
              "counterparty_bic" => "CRLYFRPPTOU",
              "counterparty_iban" => "EE383680981021245685",
              "description" => "Wonderland/4410"
            },
            {
              "amount" => "61238",
              "counterparty_name" => "Wile E Coyote",
              "counterparty_bic" => "ZDRPLBQI",
              "counterparty_iban" => "DE9935420810036209081725212",
              "description" => "//TeslaMotors/Invoice/12"
            },
            {
              "amount" => "999",
              "counterparty_name" => "Bugs Bunny",
              "counterparty_bic" => "RNJZNTMC",
              "counterparty_iban" => "FR0010009380540930414023042",
              "description" => "2020 09 24/2020 09 25/GoldenCarrot/"
            }
          ]
        }
      }

      it "returns a 200 http status code" do
        post "/transfers", :params => request_body

        expect(response.status).to eq(201)
      end

      it "stores the transfers" do
        post "/transfers", :params => request_body

        expect(Transfer.count).to eq(3)
      end

      it "updates customer's account balance" do
        post "/transfers", :params => request_body

        updated_balance = BankAccount.find(bank_account.id).balance_cents

        expect(updated_balance).to eq(93774850)
      end
    end
  end
end
