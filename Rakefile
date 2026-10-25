# frozen_string_literal: true

require "rake/testtask"

# bundle exec rake test (ou só bundle exec rake) roda todos os testes.
Rake::TestTask.new(:test) do |task|
  task.libs << "test"
  task.pattern = "test/**/*_test.rb"
end

task default: :test
