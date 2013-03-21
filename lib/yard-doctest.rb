$:.unshift File.dirname(__FILE__)
require "yard-doctest/version"
require "yard"

module YARD
  module Doctest
    autoload :Example, "yard-doctest/example_test"

    class CLI < YARD::CLI::Yardoc
      def run(*args)
        super

      end

      private
      def run_generate(checksums)
        puts "in here"
        super

      end
    end
  end
end

YARD::Tags::Library.define_tag "Shared example setup code", :example_setup, :with_title_and_text
YARD::Tags::Library.define_tag "Shared example teardown code", :example_teardown, :with_title_and_text

YARD::CLI::CommandParser.commands[:doctest] = YARD::Doctest::CLI

YARD::Templates::Engine.register_template_path File.dirname(__FILE__) + '/../templates'
