# Tesiting a kernal method.
#
# @param a Array<String>
# @return String
# @example Joins an array
#   my_join(["a", :b, 123]) # => "a,b,123"
#
def my_join(a)
  a.map(&:to_s).join(",")
end

module Foo
  # Testing a module method.
  #
  # @example Adds numerics
  #   subject = 123
  #   Foo.add_to(subject, 4) #=> 127
  #   subject #=> 123
  # @example Adds strings
  #   subject = "foo"
  #   Foo.add_to(subject, "bar") #=> "foobar"
  #   subject # => "foo"
  # @example Adds arrays
  #   subject = %w{ a b }
  #   Foo.add_to(subject, ["c"]) # => ["a", "b", "c"]
  #   subject # => %w{a b}
  # @example Errors with invalid types
  #   subject = 123
  #   #Foo.add_to(subject, "abc") # !=> TypeError
  def self.add_to(subject, object)
    subject += object
    subject
  end
end

class Bar
  attr_reader :state
  def initialize(initial)
    @state = initial
  end

  # Transitions the state for some reason.
  #
  # @example_setup
  #   @bar = Bar.new(:a)
  # @example Transitions to :b
  #   @bar.step!(:b)
  #   @bar.state # => :b
  #   @bar.step!(:a)
  #   @bar.state # => :a
  #   @bar.step!(:b)
  #   @bar.state # => :b
  #   @bar.step!(:d)
  #   @bar.state # => :b
  # @example Only transitions from a to b
  #   [:c, :d].each do |t|
  #     @bar.step!(t)
  #     @bar.state # => :a
  #   end
  def step!(next_state)
    @state = case @state
    when :a
      next_state == :b ? :b : :a
    when :b
      [:a, :c].include?(next_state) ? next_state : :b
    when :c
      :d
    else
      :a
    end
  end
end
