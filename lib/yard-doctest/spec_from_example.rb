require_relative "../yard-doctest"

module Yard::Doctest
  class SpecFromExample
    def initialize(code_object)
      @code_object = code_object
    end

  end
end
