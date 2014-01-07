require "spec_helper"
require "combustion"
require "capybara/rspec"

Combustion.initialize! :active_record, :action_controller, :action_view

require "rspec/rails"
require "capybara/rails"
