# frozen_string_literal: true

require 'rake/testtask'

Rake::TestTask.new do |task|
  task.libs << 'test'
  task.pattern = 'test/**/*_test.rb'
end

task default: :test

Rake::TestTask.new('test:workflows') do |task|
  task.libs << 'test'
  task.pattern = 'test_workflows/**/*_test.rb'
end

Rake::TestTask.new('test:package') do |task|
  task.libs << 'test'
  task.pattern = 'test_packaging/**/*_test.rb'
end

Rake::TestTask.new('test:ai') do |task|
  task.libs << 'test'
  task.pattern = 'test_ai/**/*_test.rb'
end

# Optional real-service lane: disposable PostgreSQL and a prepared browser are required.
Rake::TestTask.new('test:journey') do |task|
  task.libs << 'test'
  task.pattern = 'test_journey/**/*_test.rb'
end

# Optional independently bundled RSpec acceptance.
Rake::TestTask.new('test:rspec') do |task|
  task.libs << 'test'
  task.pattern = 'test_rspec/**/*_test.rb'
end

# Optional installed delivery extraction lane: a prepared browser is required.
Rake::TestTask.new('test:delivery') do |task|
  task.libs << 'test'
  task.pattern = 'test_delivery/**/*_test.rb'
end
