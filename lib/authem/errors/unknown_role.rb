module Authem
  class UnknownRoleError < StandardError
    def initialize(model)
      message = "Unknown authem role: #{model.inspect}"
      super message
    end
  end
end
