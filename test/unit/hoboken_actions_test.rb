require_relative "../test_helper"
require_relative "../../lib/hoboken/actions.rb"

module Hoboken
  require "thor"
  class Target < Thor::Group
    include Thor::Actions
    include Hoboken::Actions
  end

  class GemActionsTest < Test::Unit::TestCase
    attr_reader :gemfile_path, :gemfile, :target

    def setup
      @gemfile_path = File.join("test", "fixtures")
      @gemfile = File.join(gemfile_path, "Gemfile")
      @target = Target.new([], {}, destination_root: gemfile_path)
      FileUtils.copy(File.join(gemfile_path, "Gemfile.pristine"), gemfile)
    end

    def test_gem_appends_to_gemfile
      target.gem "sinatra", verbose: false
      expected =
        "source \"https://rubygems.org\"\n" +
        "ruby \"2.3.1\"\n\n" +
        "gem \"sinatra\""

      assert_equal(expected, File.read(gemfile))
    end

    def test_gem_with_version
      target.gem "sinatra", version: "1.4.7", verbose: false
      expected =
        "source \"https://rubygems.org\"\n" +
        "ruby \"2.3.1\"\n\n" +
        "gem \"sinatra\", \"~> 1.4.7\""

      assert_equal(expected, File.read(gemfile))
    end

    def test_get_with_blank_version
      target.gem "sinatra", version: "", verbose: false
      expected =
        "source \"https://rubygems.org\"\n" +
        "ruby \"2.3.1\"\n\n" +
        "gem \"sinatra\""

      assert_equal(expected, File.read(gemfile))
    end

    def test_gem_with_group
      target.gem "sinatra", version: "1.4.7", group: :test, verbose: false
      expected =
        "source \"https://rubygems.org\"\n" +
        "ruby \"2.3.1\"\n\n" +
        "gem \"sinatra\", \"~> 1.4.7\", group: :test"

      assert_equal(expected, File.read(gemfile))
    end

    def test_gem_with_multiple_groups
      target.gem "sinatra", version: "1.4.7", group: [:test, :development], verbose: false
      expected =
        "source \"https://rubygems.org\"\n" +
        "ruby \"2.3.1\"\n\n" +
        "gem \"sinatra\", \"~> 1.4.7\", group: [:test, :development]"

      assert_equal(expected, File.read(gemfile))
    end

    def test_gem_with_require
      target.gem "sinatra", version: "1.4.7", require: false, verbose: false
      expected =
        "source \"https://rubygems.org\"\n" +
        "ruby \"2.3.1\"\n\n" +
        "gem \"sinatra\", \"~> 1.4.7\", require: false"

      assert_equal(expected, File.read(gemfile))
    end

    def test_gem_with_require_and_group
      target.gem "sinatra", version: "1.4.7", require: false, group: :test, verbose: false
      expected =
        "source \"https://rubygems.org\"\n" +
        "ruby \"2.3.1\"\n\n" +
        "gem \"sinatra\", \"~> 1.4.7\", require: false, group: :test"

      assert_equal(expected, File.read(gemfile))
    end

    def test_gem_with_require_and_multiple_groups
      target.gem "sinatra", version: "1.4.7", require: false, group: [:test, :development], verbose: false
      expected =
        "source \"https://rubygems.org\"\n" +
        "ruby \"2.3.1\"\n\n" +
        "gem \"sinatra\", \"~> 1.4.7\", require: false, group: [:test, :development]"

      assert_equal(expected, File.read(gemfile))
    end

    def test_gem_multiple
      target.gem "sinatra", version: "1.4.7", verbose: false
      target.gem "thin", version: "1.7", verbose: false
      expected =
        "source \"https://rubygems.org\"\n" +
        "ruby \"2.3.1\"\n\n" +
        "gem \"sinatra\", \"~> 1.4.7\"\n" +
        "gem \"thin\", \"~> 1.7\""

      assert_equal(expected, File.read(gemfile))
    end
  end

  class IndentActionsTest < Test::Unit::TestCase
    attr_reader :text, :target

    def setup
      @target = Target.new
      @text = <<-TEXT
This is some
text that needs
to be indented.
TEXT
    end

    def test_indent_with_one_space
      expected = <<-TEXT
 This is some
 text that needs
 to be indented.
TEXT

      assert_equal(expected, target.indent(text, 1))
    end

    def test_indent_with_two_spaces
      expected = <<-TEXT
  This is some
  text that needs
  to be indented.
TEXT

      assert_equal(expected, target.indent(text, 2))
    end
  end
end
