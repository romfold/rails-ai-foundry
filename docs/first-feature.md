# Your first feature: issue an invoice

Build this in a new disposable Foundry Rails app using SQLite, for example `foundry new invoice_demo --database=sqlite3 --specs=none`. PostgreSQL remains the normal product default. The exercise works with any selected specification workflow: record its behavior there and reconcile after tests pass. None requires no workflow tooling.

Customers owns customer records and exposes registration and lookup; Billing owns invoices and HTTP delivery. Both contexts use rails_native. Billing depends on Customers' public API. There is no capability generator: create packs upstream and implement Rails code. Commands run from the application root with its locked bundle and packs-rails available in every environment.

For each file block, create parent directories and save its content at the path in the fence. Replace existing files only in this disposable tutorial app after review. Shell blocks execute in order. The phase/file annotations let archive acceptance replay these exact snippets; they are not a production task runner.

## Create the packs

```yaml file=package.yml phase=setup
enforce_dependencies: true
enforce_privacy: false
```

```yaml file=packwerk.yml phase=setup
require:
- packwerk-extensions
```

```yaml file=packs.yml phase=setup
pack_paths:
- packs/*
```

```sh phase=setup
bundle binstubs packwerk
bundle exec packs create packs/customers --enforce-dependencies --enforce-privacy --no-enforce-layers
bundle exec packs create packs/billing --enforce-dependencies --enforce-privacy --no-enforce-layers
bundle exec packs add_dependency packs/billing packs/customers
bundle exec packs add_dependency packs/billing .
bundle exec packs add_dependency packs/customers .
```

```yaml file=packs/customers/foundry.yml phase=setup
schema: 1
namespace: Customers
profile: rails_native
patterns:
  events: none
  cqrs: none
capabilities: {}
```

```yaml file=packs/billing/foundry.yml phase=setup
schema: 1
namespace: Billing
profile: rails_native
patterns:
  events: none
  cqrs: none
capabilities: {}
```

The root dependency allows pack code to use the shell's ApplicationRecord and ApplicationController. Root privacy is disabled for this small tutorial; in an existing application preserve its public-path policy instead. Pack privacy stays enabled. Upstream packs does not write foundry.yml; these files explicitly add architectural intent.

## Persist the business state

Migrations and Rails base classes belong to the shell. Customer and invoice behavior belongs to its owner. Monetary amounts use integer cents. Customer lookup returns only the fields Billing needs, without exposing a private persistence object.

```ruby file=app/models/application_record.rb phase=feature
# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end
```

```ruby file=app/controllers/application_controller.rb phase=feature
# frozen_string_literal: true

class ApplicationController < ActionController::Base
end
```

```ruby file=db/migrate/20260916000000_create_invoice_feature.rb phase=feature
# frozen_string_literal: true

class CreateInvoiceFeature < ActiveRecord::Migration[7.1]
  def change
    create_table :customers_customers do |table|
      table.string :name, null: false
    end
    create_table :billing_invoices do |table|
      table.bigint :customer_id, null: false
      table.integer :amount_cents, null: false
    end
    add_foreign_key :billing_invoices, :customers_customers, column: :customer_id
    add_check_constraint :billing_invoices, 'amount_cents > 0', name: 'positive_invoice_amount'
  end
end
```

```ruby file=packs/customers/app/models/customers/customer.rb phase=feature
# frozen_string_literal: true

module Customers
  class Customer < ApplicationRecord
    self.table_name = 'customers_customers'

    validates :name, presence: true
  end
end
```

```ruby file=packs/customers/app/public/customers/lookup.rb phase=feature
# frozen_string_literal: true

module Customers
  module Lookup
    def self.call(id)
      customer = Customer.find(id)
      { id: customer.id, name: customer.name }
    end
  end
end
```

```ruby file=packs/customers/app/public/customers/register.rb phase=feature
# frozen_string_literal: true

module Customers
  module Register
    def self.call(name:)
      Customer.create!(name: name).id
    end
  end
end
```

```ruby file=packs/billing/app/models/billing/invoice.rb phase=feature
# frozen_string_literal: true

module Billing
  class Invoice < ApplicationRecord
    self.table_name = 'billing_invoices'

    validates :customer_id, presence: true
    validates :amount_cents, numericality: { only_integer: true, greater_than: 0 }
  end
end
```

```ruby file=packs/billing/app/operations/billing/issue_invoice.rb phase=feature
# frozen_string_literal: true

require 'dry/operation'

module Billing
  class IssueInvoice < Dry::Operation
    skip_prepending

    def call(customer_id:, amount_cents:)
      result = nil
      ApplicationRecord.transaction(requires_new: true) do
        result = steps { step issue(customer_id, amount_cents) }
        raise ActiveRecord::Rollback if result.failure?
      end
      result
    end

    private

    def issue(customer_id, amount_cents)
      customer = Customers::Lookup.call(customer_id)
      invoice = Invoice.new(customer_id: customer.fetch(:id), amount_cents: amount_cents)
      invoice.save ? Success(invoice) : Failure(invoice.errors.full_messages)
    rescue ActiveRecord::RecordNotFound
      Failure(:unknown_customer)
    end
  end
end
```

The operation owns one native result boundary and rolls back a failed result. The controller below only reads; invoice creation is invoked through the operation in this exercise. Add authentication and application authorization before exposing writes to users.

## Deliver and test inside the pack

```ruby file=config/routes.rb phase=feature
# frozen_string_literal: true

Rails.application.routes.draw do
  draw :billing
end
```

```ruby file=packs/billing/config/routes/billing.rb phase=feature
# frozen_string_literal: true

namespace :billing do
  resources :invoices, only: :show
end
```

```ruby file=packs/billing/app/controllers/billing/invoices_controller.rb phase=feature
# frozen_string_literal: true

module Billing
  class InvoicesController < ApplicationController
    def show
      @invoice = Invoice.find(params[:id])
    end
  end
end
```

```erb file=packs/billing/app/views/billing/invoices/show.html.erb phase=feature
<p>Invoice <%= @invoice.id %>: <%= @invoice.amount_cents %> cents</p>
```

```ruby file=packs/billing/test/issue_invoice_test.rb phase=feature
# frozen_string_literal: true

require 'test_helper'

class IssueInvoiceTest < ActiveSupport::TestCase
  test 'valid invoice persists and invalid invoice has no effects' do
    customer_id = Customers::Register.call(name: 'Ada')
    result = Billing::IssueInvoice.new.call(customer_id: customer_id, amount_cents: 1200)
    assert result.success?
    assert_equal 1200, Billing::Invoice.find(result.value!.id).amount_cents
    before = Billing::Invoice.count
    failure = Billing::IssueInvoice.new.call(customer_id: customer_id, amount_cents: 0)
    assert failure.failure?
    assert_equal before, Billing::Invoice.count
    missing = Billing::IssueInvoice.new.call(customer_id: -1, amount_cents: 1200)
    assert_equal :unknown_customer, missing.failure
  end
end
```

```ruby file=packs/billing/test/invoices_delivery_test.rb phase=feature
# frozen_string_literal: true

require 'test_helper'

class InvoicesDeliveryTest < ActionDispatch::IntegrationTest
  test 'pack route renders the persisted invoice' do
    customer_id = Customers::Register.call(name: 'Ada')
    invoice = Billing::IssueInvoice.new.call(customer_id: customer_id, amount_cents: 1200).value!
    get "/billing/invoices/#{invoice.id}"
    assert_response :success
    assert_includes response.body, '1200 cents'
  end
end
```

```sh phase=verify
bundle exec rails db:migrate
bundle exec rails db:migrate RAILS_ENV=test
bundle exec rails zeitwerk:check
bundle exec rails test packs/billing/test
bundle exec foundry check --sources --boundaries
```

Tests register customers through the public API; production Billing code only calls the public lookup. The selected tests are offline. Boundaries run in the isolated test environment and preserve debt. To prove data survives a fresh Rails process, create an invoice and then read it in a second runner:

```sh phase=restart
bundle exec rails runner 'customer_id = Customers::Register.call(name: "Restart proof"); Billing::IssueInvoice.new.call(customer_id: customer_id, amount_cents: 2300).value!'
bundle exec rails runner 'raise "invoice did not persist" unless Billing::Invoice.exists?(amount_cents: 2300)'
```

## Observe a boundary failure and repair it

Add this deliberate private access. A declared dependency does not grant access to Customer:

```ruby file=packs/billing/app/queries/billing/private_probe.rb phase=violation
# frozen_string_literal: true

module Billing
  class PrivateProbe
    def call(id)
      Customers::Customer.find(id)
    end
  end
end
```

```sh phase=violation
bundle exec foundry check --boundaries
```

Expect a nonzero status and a privacy violation naming Customers::Customer. Do not run packs update or regenerate package_todo.yml. Replace only the query implementation with the public API:

```ruby file=packs/billing/app/queries/billing/private_probe.rb phase=repair
# frozen_string_literal: true

module Billing
  class PrivateProbe
    def call(id)
      Customers::Lookup.call(id)
    end
  end
end
```

```sh phase=repair
bundle exec foundry check --sources --boundaries
bundle exec rails test packs/billing/test
```

Both checks should now pass. Remove the demonstration query later if the feature does not need it. Review the diff and reconcile the selected workflow with tested behavior.

## Existing roots and next steps

After installing the product skills with `bin/rails generate foundry:skills`, make the
selected feature checks executable as one required application CI step:

```sh
ruby .agents/skills/foundry-verify/scripts/verify.rb \
  --baseline packs/billing/test --caller packs/billing/test/invoices_delivery_test.rb
```

The helper runs real Minitest evidence and rejects missing/empty tests or a failed
caller. Add `--realtime --browser PATH` for features that require browser interactions.
See the installed `foundry-verify/references/verification.md` for scope, reviewed skips,
timeouts and CI integration. Review application-specific coverage; a successful helper
run does not establish all requirements automatically. Existing customized catalogs
need explicit review before installing the helper.

For an existing components/* root, preserve its packs.yml and replace the pack path in these commands/files with components/. Ruby namespaces stay Customers and Billing. The archive suite replays this variation too. Do not reset an existing application's root package policy or routes by pasting tutorial files.

Adapt this feature with foundry-add-feature: define customer authorization, invoice lifecycle and a public issuance API only when needed. Consult [packs usage](packs.md) before moves/publication and [native contexts](native-contexts.md) for optional generators. Installed copies are available under the gem's docs directory (`bundle show rails_ai_foundry`).

For a feature that requires a human to approve generated work before durable execution, see the
[reviewed ticket resolution example](reviewed-ticket-resolution.md). Its approval boundary is a
conditional application pattern; the ordinary synchronous tutorial above does not need that workflow.
