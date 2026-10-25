# frozen_string_literal: true

require "bundler/gem_tasks"
require "rake/testtask"

# bundle exec rake test (ou só bundle exec rake) roda todos os testes.
# O bundler/gem_tasks acima traz o rake build e o rake release, usados na publicação.
Rake::TestTask.new(:test) do |task|
  task.libs << "test"
  task.pattern = "test/**/*_test.rb"
end

task default: :test
