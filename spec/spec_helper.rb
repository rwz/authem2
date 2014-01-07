require "bundler/setup"
require "authem"

Dir["#{__dir__}/support/**/*.rb"].each(&method(:require))
