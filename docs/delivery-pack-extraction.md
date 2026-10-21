# Extract an existing Rails delivery feature

Use `foundry-adopt-existing-app`, `foundry-add-package` and `foundry-verify`. Read the
[delivery extraction reference](../skills/references/delivery-extraction.md) first.
This exercise starts with ordinary shell delivery and moves it into a Rails-native pack.
Models, tables, shared authentication, layout and migrations remain in the shell.
It is a copy-and-adapt guide, not an installer or an automatic refactoring command.

The complete snippets ship in the gem. In a new disposable directory, save each annotated
file and execute the shell blocks in order. The annotations support contributor replay;
no Markdown runner is needed by the application. Preserve existing files when adapting
these instructions; do not replace an established application's Gemfile, configuration,
authentication or tests with demo files. Inspect the locked `packs` CLI before using it.

The worked combination uses Rails 8.1.3.1, Minitest 5.27.0, importmap-rails 2.2.3,
Propshaft 1.3.2 and locally served Stimulus/Turbo. It is not an instruction to upgrade
an existing app. A working preinstalled Chrome/ChromeDriver is required for system tests.
No provider, CDN or npm download is used by the example. The acceptance bundle records
exact resolved dependencies; other pipelines need their own native asset wiring.
JSON 2.21.2 is explicit because JSON 3's parsing interface is incompatible with this
Rails cookie-decoding combination. Preserve existing consumers' independently verified locks.

## 1. Characterize ordinary shell behavior

Use Ruby 3.4.10 and a new disposable directory. Install the built Foundry gem into your
chosen gem environment first. Resolve dependencies once, then retain the resulting lock.
The demo login accepts two public synthetic identities; **it is not production authentication**.
Real extraction preserves the application's existing authentication and authorization.

```ruby file=Gemfile phase=base
source 'https://rubygems.org'
gem 'rails', '8.1.3.1'
gem 'packs-rails', '0.1.0'
gem 'sqlite3', '2.9.6'
gem 'puma', '6.6.1'
gem 'propshaft', '1.3.2'
gem 'importmap-rails', '2.2.3'
gem 'json', '2.21.2'
gem 'stimulus-rails', '1.3.4'
gem 'turbo-rails', '2.0.23'
gem 'rake', '13.4.2'
group :development, :test do
  gem 'rails_ai_foundry', '1.0.0'
  gem 'minitest', '5.27.0'
  gem 'capybara', '3.40.0'
  gem 'selenium-webdriver', '4.49.0'
end
```

```ruby file=config/boot.rb phase=base
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)
require 'bundler/setup'
```

```ruby file=config/application.rb phase=base
require_relative 'boot'
require 'rails'
require 'active_record/railtie'
require 'active_job/railtie'
require 'action_controller/railtie'
require 'rails/test_unit/railtie' unless ENV['RAILS_ENV'] == 'production'
Bundler.require(*Rails.groups)
module DeliveryDemo
  class Application < Rails::Application
    config.load_defaults 8.1
    config.eager_load = Rails.env.production?
    config.enable_reloading = Rails.env.development?
    config.secret_key_base = 'disposable-delivery-extraction-example-only'
    config.hosts.clear
    config.active_support.deprecation = :stderr
    config.public_file_server.enabled = true
    config.action_dispatch.show_exceptions = :none if Rails.env.test?
  end
end
```

```ruby file=config/environment.rb phase=base
require_relative 'application'
Rails.application.initialize!
```

```ruby file=bin/rails phase=base
#!/usr/bin/env ruby
APP_PATH = File.expand_path('../config/application', __dir__)
require_relative '../config/boot'
require 'rails/commands'
```

```ruby file=Rakefile phase=base
require_relative 'config/application'
Rails.application.load_tasks
```

```ruby file=config.ru phase=base
require_relative 'config/environment'
run Rails.application
```

```yaml file=config/database.yml phase=base
default: &default
  adapter: sqlite3
  pool: 5
  timeout: 5000
development:
  <<: *default
  database: storage/development.sqlite3
test:
  <<: *default
  database: storage/test.sqlite3
production:
  <<: *default
  database: storage/development.sqlite3
```

```ruby file=db/migrate/20261014000000_create_documents.rb phase=base
class CreateDocuments < ActiveRecord::Migration[8.1]
  def change
    create_table :documents do |t|
      t.string :owner, null: false
      t.string :body, null: false
      t.timestamps
    end
    create_table :searches do |t|
      t.string :owner, null: false
      t.string :query, null: false
      t.timestamps
    end
  end
end
```

```ruby file=db/seeds.rb phase=base
Document.find_or_create_by!(owner: 'one', body: 'Public to One')
Document.find_or_create_by!(owner: 'two', body: 'Private to Two')
Search.find_or_create_by!(owner: 'one', query: 'Existing search history')
```

```ruby file=app/models/application_record.rb phase=base
class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class
end
```

```ruby file=app/models/document.rb phase=base
class Document < ApplicationRecord
end
```

```ruby file=app/models/search.rb phase=base
class Search < ApplicationRecord
end
```

```ruby file=app/controllers/application_controller.rb phase=base
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
end
```

```ruby file=app/controllers/demo_sessions_controller.rb phase=base
class DemoSessionsController < ApplicationController
  def new
  end

  def create
    return head :unauthorized unless %w[one two].include?(params[:identity])

    session[:viewer] = params[:identity]
    redirect_to searches_path, status: :see_other
  end
end
```

```erb file=app/views/demo_sessions/new.html.erb phase=base
<h1>Disposable demo login</h1>
<%= form_with url: demo_session_path do |form| %>
  <%= form.label :identity, 'Identity' %>
  <%= form.text_field :identity %>
  <%= form.submit 'Sign in' %>
<% end %>
```

```ruby file=app/controllers/searches_controller.rb phase=base
class SearchesController < ApplicationController
  before_action :authenticate

  def index
    @documents = Document.where(owner: session[:viewer]).where('body LIKE ?', "%#{params[:q]}%").order(:id).limit(100)
  end

  def create
    Search.create!(owner: session[:viewer], query: params[:q].to_s)
    redirect_to searches_path(q: params[:q]), status: :see_other
  end

  private

  def authenticate
    redirect_to new_demo_session_path unless session[:viewer]
  end
end
```

```ruby file=app/helpers/searches_helper.rb phase=base
module SearchesHelper
  def result_label(document)
    "Document: #{document.body}"
  end
end
```

```erb file=app/views/layouts/application.html.erb phase=base
<!doctype html><html><head><title>Delivery extraction</title>
<%= csrf_meta_tags %><%= javascript_importmap_tags %>
<link rel="icon" href="data:,"></head><body><%= yield %></body></html>
```

```erb file=app/views/searches/index.html.erb phase=base
<h1>Search</h1>
<label for="draft">Unsubmitted draft</label><input id="draft" name="draft">
<%= form_with url: searches_path, data: { turbo_frame: 'results' } do |form| %>
  <%= form.label :q, 'Query' %><%= form.text_field :q, value: params[:q] %>
  <%= form.submit 'Search' %>
<% end %>
<turbo-frame id="results">
  <section data-controller="search-results">
    <p data-search-results-target="status">Loading</p>
    <% @documents.each do |document| %>
      <article id="<%= dom_id(document) %>"><%= result_label(document) %></article>
    <% end %>
    <button type="button" data-action="search-results#reveal">Show details</button>
    <p data-search-results-target="details" hidden>Feature controller connected</p>
  </section>
</turbo-frame>
```

```javascript file=app/javascript/application.js phase=base
import '@hotwired/turbo-rails'
import { Application } from '@hotwired/stimulus'
import SearchResultsController from 'controllers/search_results_controller'
const application = Application.start()
application.register('search-results', SearchResultsController)
```

```javascript file=app/javascript/controllers/search_results_controller.js phase=base
import { Controller } from '@hotwired/stimulus'
export default class extends Controller {
  static targets = ['status', 'details']
  connect() { this.statusTarget.textContent = 'Ready' }
  reveal() { this.detailsTarget.hidden = false }
}
```

```ruby file=config/importmap.rb phase=base
pin 'application'
pin '@hotwired/turbo-rails', to: 'turbo.min.js'
pin '@hotwired/stimulus', to: 'stimulus.min.js'
pin_all_from 'app/javascript/controllers', under: 'controllers'
```

```ruby file=config/routes.rb phase=base
Rails.application.routes.draw do
  resource :demo_session, only: %i[new create]
  resources :searches, only: %i[index create]
end
```

```ruby file=test/test_helper.rb phase=base
ENV['RAILS_ENV'] = 'test'
require_relative '../config/environment'
require 'rails/test_help'
class ActiveSupport::TestCase
  setup do
    Search.delete_all
    Document.delete_all
    @mine = Document.create!(owner: 'one', body: 'Public to One')
    @foreign = Document.create!(owner: 'two', body: 'Private to Two')
  end
end
```

```ruby file=test/models/document_test.rb phase=base
require 'test_helper'
class DocumentTest < ActiveSupport::TestCase
  test 'shell model persists identity and content' do
    assert_equal 'Public to One', Document.find(@mine.id).body
    assert_equal 'documents', Document.table_name
  end
end
```

```ruby file=test/requests/search_test.rb phase=base
require 'test_helper'
class SearchDeliveryTest < ActionDispatch::IntegrationTest
  test 'authentication remains required' do
    get searches_path
    assert_redirected_to new_demo_session_path
  end

  test 'renders only authorized records using the local helper' do
    sign_in
    get searches_path
    assert_response :success
    assert_select "#document_#{@mine.id}", text: 'Document: Public to One'
    assert_select "#document_#{@foreign.id}", count: 0
  end

  test 'URL and history ownership survive extraction' do
    sign_in
    token = Nokogiri::HTML(response.body).at_css('meta[name=csrf-token]')['content']
    post searches_path, params: { q: 'Public', owner: 'two' }, headers: { 'X-CSRF-Token' => token }
    assert_response :see_other
    assert_redirected_to searches_path(q: 'Public')
    assert_equal [['one', 'Public']], Search.pluck(:owner, :query)
    follow_redirect!
    assert_response :success
  end

  private

  def sign_in
    get new_demo_session_path
    token = Nokogiri::HTML(response.body).at_css('input[name=authenticity_token]')['value']
    post demo_session_path, params: { identity: 'one', authenticity_token: token }
    follow_redirect!
  end
end
```

```ruby file=test/application_system_test_case.rb phase=base
require 'test_helper'
require 'capybara/rails'
require 'selenium-webdriver'
class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome do |options|
    %w[--disable-background-networking --disable-component-update --disable-sync --no-first-run].each do |argument|
      options.add_argument(argument)
    end
  end
  Capybara.server_host = '127.0.0.1'
  Capybara.default_max_wait_time = 3
end
```

```ruby file=test/system/search_test.rb phase=base
require 'application_system_test_case'
class SearchBrowserTest < ApplicationSystemTestCase
  test 'native Turbo and Stimulus preserve authorization and draft' do
    visit new_demo_session_path
    fill_in 'Identity', with: 'one'
    click_button 'Sign in'
    assert_selector '#results', text: 'Document: Public to One'
    assert_no_selector '#results', text: 'Private to Two'
    assert_selector '#results', text: 'Ready'
    fill_in 'Unsubmitted draft', with: 'Keep this draft'
    fill_in 'Query', with: 'absent'
    click_button 'Search', exact: true
    assert_no_selector '#results article'
    assert_field 'Unsubmitted draft', with: 'Keep this draft'
    click_button 'Show details'
    assert_selector '#results', text: 'Feature controller connected'
    fill_in 'Query', with: 'Public'
    click_button 'Search', exact: true
    assert_selector "#document_#{@mine.id}", text: 'Document: Public to One'
    assert_field 'Unsubmitted draft', with: 'Keep this draft'
  end
end
```

```sh phase=baseline
bundle install --local
ruby bin/rails db:prepare
ruby bin/rails db:seed
ruby bin/rails generate foundry:skills --target=agents
ruby .agents/skills/foundry-verify/scripts/verify.rb --caller test/requests/search_test.rb --realtime --browser test/system/search_test.rb --timeout 120
```

Record the starting commit, lockfile hash, database row identities/content/timestamps, and
actual baseline results. A zero-test exit does not establish a baseline. Stop and report
framework incompatibilities; do not upgrade dependencies or install an adapter to hide them.
A separately authorized browser review can add evidence, but cannot replace blocked tests.

## 2. Extract delivery, retaining shell ownership

Choose `SearchExperience` because the shell already owns `Search`. Existing profiles and
patterns follow application intent; this example explicitly chooses rails_native/none/none.
Use `components/` instead of `packs/` throughout for an existing custom root. Never replace
an existing `packs.yml`, workflow configuration or package policy with these demo settings.

```yaml file=packs.yml phase=extract
pack_paths: ['packs/*']
```

```yaml file=package.yml phase=extract
enforce_dependencies: true
dependencies: []
```

```yaml file=packwerk.yml phase=extract
require:
  - packwerk-extensions
exclude:
  - '**/test/**/*'
  - 'tmp/**/*'
  - 'vendor/**/*'
```

```yaml file=config/foundry.yml phase=extract
schema: 1
workflow:
  specs: none
```

```ruby file=bin/packwerk phase=extract
#!/usr/bin/env ruby
require 'bundler/setup'
require 'stringio'
load Gem.bin_path('packwerk', 'packwerk')
```

```sh phase=extract
chmod +x bin/packwerk
bundle exec packs create packs/search --enforce-dependencies --enforce-privacy --no-enforce-layers
```

```yaml file=packs/search/package.yml phase=extract
enforce_dependencies: true
enforce_privacy: true
enforce_layers: false
dependencies:
  - '.'
```

```yaml file=packs/search/foundry.yml phase=extract
schema: 1
namespace: SearchExperience
profile: rails_native
patterns:
  events: none
  cqrs: none
capabilities: {}
```

Use reviewed file moves. The following commands are for this disposable fixture only;
record an equivalent patch in an existing application. The views, JavaScript and tests
move without behavior changes. Namespace declarations alone change in controller/helper.

```sh phase=extract
mkdir -p packs/search/app/controllers/search_experience packs/search/app/helpers/search_experience packs/search/app/views/search_experience packs/search/app/javascript/controllers packs/search/test/requests packs/search/test/system
mv app/controllers/searches_controller.rb packs/search/app/controllers/search_experience/searches_controller.rb
mv app/helpers/searches_helper.rb packs/search/app/helpers/search_experience/searches_helper.rb
mv app/views/searches packs/search/app/views/search_experience/searches
mv app/javascript/controllers/search_results_controller.js packs/search/app/javascript/controllers/search_results_controller.js
mv test/requests/search_test.rb packs/search/test/requests/search_test.rb
mv test/system/search_test.rb packs/search/test/system/search_test.rb
ruby -e 'p="packs/search/app/controllers/search_experience/searches_controller.rb"; File.write(p, File.read(p).sub("class SearchesController", "class SearchExperience::SearchesController"))'
ruby -e 'p="packs/search/app/helpers/search_experience/searches_helper.rb"; File.write(p, File.read(p).sub("module SearchesHelper", "module SearchExperience::SearchesHelper"))'
```

```ruby file=config/routes.rb phase=extract
Rails.application.routes.draw do
  resource :demo_session, only: %i[new create]
  resources :searches, only: %i[index create], controller: 'search_experience/searches'
end
```

```ruby file=config/importmap.rb phase=extract
pin 'application'
pin '@hotwired/turbo-rails', to: 'turbo.min.js'
pin '@hotwired/stimulus', to: 'stimulus.min.js'
pin_all_from 'packs/search/app/javascript/controllers', under: 'controllers'
```

```ruby file=config/initializers/search_assets.rb phase=extract
Rails.application.config.assets.paths << Rails.root.join('packs/search/app/javascript')
```

`packs-rails` supplies pack Rails paths and view lookup. It does not guarantee that your
asset pipeline pins the moved JavaScript. Here importmap names stay stable and Propshaft
receives the pack JavaScript directory. Keep `app/javascript/application.js`, shared layout,
base classes, `Document`, `Search`, tables and migrations unchanged. No reverse dependency
is needed just to dispatch a route by its controller string; do not expose the controller
as a public business API to silence Packwerk.

## 3. Verify behavior and loading after extraction

Review and retain your own verification command. Do not overwrite an existing command.
The helper adds pack tests to the root baseline; browser selections remain explicit.

```ruby file=bin/verify-feature phase=verify
#!/usr/bin/env ruby
require 'rbconfig'
Dir.chdir(File.expand_path('..', __dir__))
exec RbConfig.ruby, '.agents/skills/foundry-verify/scripts/verify.rb', '--include-pack-tests',
  '--caller', 'packs/search/test/requests/search_test.rb', '--realtime',
  '--browser', 'packs/search/test/system/search_test.rb', '--timeout', '120'
```

```sh phase=verify
ruby bin/verify-feature
bundle exec foundry check --sources --format=json
ruby bin/rails zeitwerk:check
ruby bin/rails assets:precompile
env RAILS_ENV=test ruby bin/packwerk validate
env RAILS_ENV=test ruby bin/packwerk check
```

Run Packwerk only with isolated test state (`RAILS_ENV=test`); it can boot the app. Confirm
exact context path, namespace/profile/patterns and active enforcement, not merely exit zero.
Do not regenerate accepted debt. The Ruby class reload check below is independent of
frontend caching. Remove disposable precompiled assets before testing changed frontend
behavior so stale compiled files cannot hide moved-source errors.

Check development reloading in development, not a test environment that disables it:

```sh phase=reload
ruby bin/rails runner 'before = SearchExperience::SearchesController; Rails.application.reloader.reload!; raise "controller did not reload" if before.equal?(SearchExperience::SearchesController)'
```

In a fresh process, run production eager loading with `RAILS_ENV=production` and
`BUNDLE_WITHOUT=development:test`. Require SearchExperience::SearchesController to load
and reject `Gem.loaded_specs.key?('rails_ai_foundry')`. Keep packs-rails in production.
Compare the root-owned records, schema and lock with the starting checkpoint.

In disposable copies, break route dispatch, helper/view lookup, JavaScript wiring and
authorization one at a time. Require a specific HTTP/browser failure after a healthy run,
then restore and rerun. An intentional root reference to the private pack controller must
fail Packwerk. A helper that silently omits a planned pack file must fail loaded-file evidence.
Never count a failed browser startup as successful authorization-fault detection.

## 4. Deliver guidance and roll back safely

Existing installations receive the new reference through [reviewed skill upgrades](skill-upgrades.md).
Assess first, apply the review digest, resolve every pending file deliberately and rerun
behavioral verification. `keep_local` preserves customized instructions; it does not mean
those bytes match the incoming catalog. Preserve workflow selection, project instructions,
accepted debt and unrelated skills. Instruction upgrades do not change application code.

Rollback reverses the recorded delivery moves, namespace/route/asset edits and newly added
package configuration. Keep shell tables and data. Restore the original receipt only through
the reviewed rollback procedure when its preimages still match; never erase later edits.
Each checkpoint remains useful on its own. The separate Campfire browser evidence neither
changes this fixture's acceptance nor closes Campfire's blocked framework tests.
