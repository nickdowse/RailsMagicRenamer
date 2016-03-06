require 'rails_magic_renamer'
require 'rubygems'
require 'spork'
require 'active_support/all'


Spork.prefork do

  # From rspec generator
  ENV["RAILS_ENV"] ||= 'test'
  require 'rspec/autorun'

  RSpec.configure do |config|
    config.order = "random"
  end

end
