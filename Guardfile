
clearing :on
notification :terminal_notifier

group :ruby do

  guard :minitest, all_on_start: false, spring: false do
    # with Minitest::Unit
    watch(%r{^lib/(.+)\.rb$})     { |m| "test/#{m[1]}_test.rb" }
    watch(%r{^test/.+_test\.rb$})
    watch('test/test_helper.rb')  { "test" }
    # Rails example
    watch(%r{^app/models/(.+)\.rb$})                   { |m| "test/unit/#{m[1]}_test.rb" }
    watch(%r{^app/controllers/(.+)\.rb$})              { |m| "test/functional/#{m[1]}_test.rb" }
    watch(%r{^app/views/.+\.rb$})                      { "test/integration" }
    watch('app/controllers/application_controller.rb') { ["test/functional", "test/integration"] }
  end

end
