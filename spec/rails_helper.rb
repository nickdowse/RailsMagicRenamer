require 'rails/all'

require 'factory_girl'
require 'factory_girl_rails'



require 'support/sample_app_rails_4/config/environment'
require 'rspec/rails'

# ActiveRecord::Migration.maintain_test_schema!

# set up db
# be sure to update the schema if required by doing
# - cd spec/support/sample_app_rails_4
# - rake db:migrate
ActiveRecord::Schema.verbose = false
load 'support/sample_app_rails_4/db/schema.rb' # use db agnostic schema by default

require 'support/sample_app_rails_4/factory_girl'
# require 'support/sample_app_rails_4/factories'
require 'spec_helper'

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!
  config.include Capybara::DSL
end
