# README

# Credit Transfers API

The Credit Transfers API application aims to perform transactions between bank accounts. Currently, the application contains only one use case related to sending payments from Qonto customers to other bank accounts.

## Implementation

Given the time constraints for the challenge, it was decided to use Rails as a web framework and SQLite3 as the proposed database to save time in the initial project setup and focus on developing the functionality and organization of the application.

The project is essentially organized into three layers:

- API layer - where controllers as adapters for HTTP requests are located.
- Application layer - where application use cases and some objects encapsulating input data are located
- Domain and database layer - where entities like `BankAccount` and `Transfer` are located. I would like to separate these two responsibilities and have a business layer separate from the database adaptation layer, for instance. However, given the time limit for the challenge, I decided to follow a simpler approach already proposed by the framework.
Thus, the application flow will always be `Controllers -> UseCases -> Models`. Models do not depend on UseCases, and UseCases do not depend on Controllers. All dependencies are managed through dependency injection, facilitating unit tests.

### /transfers API
Given that the JSON files used as samples provide bank account data in the request body, it was decided to create the `/transfers` resource instead of the `/bank_account/:id/transfers` resource.

### Commands

I decided to use the concept of Commands to encapsulate input data from HTTP calls. Some validations should have been implemented but were skipped due to time constraints.

### UseCases

UseCases are the orchestrators of the application. They manage database transactions, such as in the process of creating transfers and updating the financial balance, and prepare the data to be sent for business rule execution.

### Models

As mentioned earlier, the use of the Rails framework brings some coupling problems in the Models layer. Here, classes are responsible for serving as an entity for connection and mapping with database tables and also for executing business rules.

### Tests

The application has two types of tests:

- Unit tests: used in the UseCase layer for easy manipulation of dependencies and testing different scenarios using mocks.
- Integration tests: controllers are tested in an integrated way, without using mocks. This brings the benefit of testing important features of the application in its real state.

## Issues encountered

- <b>Transaction Isolation Level</b>: The transaction opened in the process of creating transfers and updating the financial balance has the lowest isolation level, `read_uncommitted`. My intention, considering a real scenario of an application running on multiple nodes using the same database, is to use a safer and more restricted isolation level for such a critical operation. `Serializable` would be my choice. However, when changing the isolation level, I noticed that SQLite3 does not support this type of isolation by default: `"SQLite3 only supports the read_uncommitted transaction isolation level."` To make this change, it would be necessary to allow the `shared_cache` of the database, which can bring some benefits like performance but also brings some problems such as the complexity of managing this shared cache in distributed systems and some concurrency issues. Then, I decided to move with the lowest level and explain my approach in the Improvements section.
- <b>Input values for the `amount` attribute</b>: I had a lot of indecision about the values received in the amount field of the JSON request. My doubt was whether values without decimal places should be considered as if they had the decimal place or not, for example, if <i>98234</i> would be <i>98234.0</i> or <i>982.34</i>. I decided to go with the first option.

## Improvements

Good improvements could be applied to the application if there were more time or team collaboration.

- Use of a relational database such as PostgreSQL, for example, mainly for using transactions with other isolation levels.
- Addition of constraints on database tables, such as avoiding the entry of null values.
- Validation of input data, such as checking if the amount field value is positive, and preventing SQL injection for security reasons.
- Addition of more logs throughout the application.
- Change the resource `/transfers` in the API to a nested resource `/bank_account/:id/transfers` and avoid receiving the raw bank account data in the request body.
- Better API responses for `/transfers` endpoint.
- Migration to a Hexagonal architecture (domains/repositories).
- Docker and docker-compose for easier local execution.

## Up and Running

<b>Dependencies:</b>

- Ruby version 3.1.1

First, install the project dependencies:

```bash
bundle install
```

Add the `qonto_accounts.sqlite3` file to the `db/` folder and change the value of the `database` key in the `database.yml` file.
```yml
development:
  <<: *default
  database: db/qonto_accounts.sqlite3
```

Then, create the SQLite database and its predefined tables with the following commands:

```bash
rails db:create
rails db:migrate
```

After running these commands, the `db/schema.rb` file will be automatically created.

Start the application to receive HTTP calls:

```bash
rails s
```

Make a request like the following to create new transfers:

```curl
curl --location 'http://localhost:3000/transfers' \
--header 'Accept: application/json' \
--header 'Content-Type: application/json' \
--data '{
  "organization_name": "ACME Corp",
  "organization_bic": "OIVUSCLQXXX",
  "organization_iban": "FR10474608000002006107XXXXX",
  "credit_transfers": [
    {
      "amount": "23.17",
      "counterparty_name": "Bip Bip",
      "counterparty_bic": "CRLYFRPPTOU",
      "counterparty_iban": "EE383680981021245685",
      "description": "Neverland/6318"
    },
    {
      "amount": "982.34",
      "counterparty_name": "Wile E Coyote",
      "counterparty_bic": "ZDRPLBQI",
      "counterparty_iban": "DE9935420810036209081725212",
      "description": "//Spacex/AJGRBX/32"
    },
    {
      "amount": "8024.99",
      "counterparty_name": "Bugs Bunny",
      "counterparty_bic": "RNJZNTMC",
      "counterparty_iban": "FR0010009380540930414023042",
      "description": "2020/DuckSeason/"
    },
    {
      "amount": "200",
      "counterparty_name": "Daffy Duck",
      "counterparty_bic": "DDFCNLAM",
      "counterparty_iban": "NL24ABNA5055036109",
      "description": "2020/RabbitSeason/"
    }
  ]
}'
```

## Tests
To run the tests, just type:
```bash
rspec spec/
```
