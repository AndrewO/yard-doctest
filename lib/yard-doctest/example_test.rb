require "minitest/unit"
require "ripper"


module YARD::Doctest
  class Example < MiniTest::Unit::TestCase
    def initialize(*args)
      super
      @binding = get_binding
    end
    
    def setup
      self.class.example_setup.each {|code| code.run(@binding)}
    end

    def run_test(title)
      self.class.example_for(title, &method(:get_operation)).each {|code|
        code.run(@binding)
      }
    end

    def teardown
      self.class.example_teardown.each {|code| code.run(@binding) }
    end

    private
    def get_binding
      binding
    end

    def get_operation(op, file, lineno)
      # TODO: Other assertions? Make plugable?
      case op
      when :"=>"
        method(:assert_equal)
      when :"!=>"
        method(:assert_raises)
      else
        ->(e,a) { flunk("Unkown assertion operator: #{op}") }
      end
    end

    class CodeSegment
      def initialize(code, file, lineno)
        @code, @file, @lineno = code, file, lineno
      end

      def run(binding)
        eval @code, binding, @file, @lineno
      end
    end

    class ComparesCodeSegments
      def initialize(actual, expected, &assertion)
        @actual, @expected, @assertion = actual, expected, assertion
      end

      def run(binding)
        actual_result = @actual.run(binding)
        # Eval the expectation second, using the same binding. Allows for
        # referencing variables in expectations. Not sure if this is a good
        # thing, but seems like something people would want.
        expected_result = @expected.run(binding)
        @assertion.call(expected_result, actual_result)
      end
    end

    class << self
      def example_methods
        (@code_object ? @code_object.tags(:example) : []).map(&:name)
      end

      def for(code_object)
        Class.new(self) {
          @code_object = code_object
        }
      end

      def example_setup
        [
          CodeSegment.new(%{require "./#{@code_object.file}"}, "(example runner)", 1),
          if tag = @code_object.tag(:example_setup)
            CodeSegment.new(tag.text, *file_and_line(tag))
          end
        ].compact
      end

      def example_teardown
        [  
          if tag = @code_object.tag(:example_teardown)
            CodeSegment.new(tag.text, *file_and_line(tag))
          end
        ].compact
      end

      def example_for(title, &assertion_builder)
        if tag = @code_object.tags(:example).find {|t| t.name == title}
          assertions = extract_from_text(tag.text)
          build_examples(
            tag.text.lines.to_a, assertions, *file_and_line(tag)
          ).map do |(actual, expected, op)|
            puts "a: #{actual}, e: #{expected}, o: #{op}"
            ComparesCodeSegments.new(
              CodeSegment.new(*actual),
              CodeSegment.new(*expected),
              &assertion_builder.call(*op)
            )
          end
        else
          raise "Could not find example: #{title}"
        end
      end

      private
      def file_and_line(tag)
        [tag.object.file, tag.object.line]
      end

      def extract_from_text(text)
        extractor = CommentExtractor.new(text).tap(&:lex).assertions
      end

      def build_examples(lines, assertions, file, start_lineno)
        prev = 0
        assertions.map do |(rel_lineno, (op, expectation))|
          [
            [lines[prev...rel_lineno].join, file, start_lineno + prev],
            [expectation, file, start_lineno + rel_lineno],
            [op.to_sym, file, start_lineno + rel_lineno]
          ].tap { prev = rel_lineno }
        end
      end
    end

    class CommentExtractor < Ripper::Lexer
      attr_reader :assertions
      def initialize(*args)
        super
        @assertions = {}
      end

      def on_comment(exp)
        @assertions[lineno] = process_expectation(exp)
        puts "assertions: #{@assertions}"
        exp
      end

      private
      def process_expectation(string)
        #(optional space)EXPECTATION METHOD(space)EXPECTATION VALUE
        if md = /^#\s*(.+)\s+(.+)$/.match(string)
          [md[1].to_sym, md[2]]
        else
          [nil, ""]
        end
      end

    end
  end
end

class MiniTest::Unit
  def run_examples
    _run_anything :example
  end

  def example_suite_header(suite)
    puts "suite: #{suite}"
  end

  class TestCase
    def self.example_suites
      self.test_suites.find_all {|ts|
        ts.respond_to?(:example_methods)
      }.reject {|s|
        s.example_methods.empty?
      }.tap {|es| puts "examples suites: #{es}"}
    end
  end
end
