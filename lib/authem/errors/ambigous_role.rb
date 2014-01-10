module Authem
  class AmbigousRoleError < StandardError
    def initialize(model, match)
      message = "Ambigous match for #{model.inspect}: #{match * ', '}"
      super message
    end
  end
end
