require "yard-doctest"
require "minitest/unit"
require "pry"

def init
  results = run_examples(object)
  super
end

def run_examples(object)
  MiniTest::Unit.new.run([YARD::Doctest::Example.for(object)])
end
