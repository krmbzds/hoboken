require "test/unit"
require "fileutils"

$hoboken_counter = 0
DESTINATION = File.expand_path("../tmp", __FILE__)
FileUtils.rm_rf(DESTINATION)

class IntegrationTestCase < Test::Unit::TestCase
  def run_hoboken(command, **opts)
    options = Array.new.tap do |o|
      o << "--git" if opts.fetch(:git) { false }
      o << "--tiny" if opts.fetch(:tiny) { false }
      o << "--type=#{opts[:type]}" if opts.has_key?(:type)
      o << "--ruby-version=#{opts[:ruby_version]}" if opts.has_key?(:ruby_version)
    end

    $hoboken_counter += 1
    bin_path = File.expand_path("../../bin/hoboken", __FILE__)

    `#{bin_path} #{command} #{DESTINATION}/#{$hoboken_counter}/sample #{options.join(" ")}`
    yield
  ensure
    FileUtils.rm_rf("#{DESTINATION}/#{$hoboken_counter}")
  end

  def execute(command)
    current_path = Dir.pwd
    FileUtils.cd("#{DESTINATION}/#{$hoboken_counter}/sample")
    `bundle install` unless File.exists?("Gemfile.lock")
    `#{command}`
  ensure
    FileUtils.cd(current_path)
  end

  def assert_file(filename, *contents)
    full_path = File.join(DESTINATION, $hoboken_counter.to_s, "sample", filename)
    assert_block("expected #{filename.inspect} to exist") do
      File.exists?(full_path)
    end

    unless contents.empty?
      read = File.read(full_path)
      contents.each do |content|
        assert_block("expected #{filename.inspect} to contain #{content}:\n#{read}") do
          read =~ content
        end
      end
    end
  end

  def assert_directory(name)
    assert_block("expected #{name} directory to exist") do
      File.directory?(File.join(DESTINATION, $hoboken_counter.to_s, "sample", name))
    end
  end

  def refute_directory(name)
    assert_block("did not expect directory #{name} to exist") do
      !File.directory?(File.join(DESTINATION, $hoboken_counter.to_s, "sample", name))
    end
  end
end