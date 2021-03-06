module Hoboken
  module Actions
    def gem(name, opts={})
      verbose = opts.has_key?(:verbose) ? opts.delete(:verbose) : true
      version = opts.has_key?(:version) ? opts.delete(:version) : nil

      parts = [name.inspect]
      parts << "~> #{version}".inspect unless version.nil? || version.empty?
      opts.each { |k, v| parts << "#{k}: #{v.inspect}" }
      append_file("Gemfile", "\ngem #{parts.join(", ")}", verbose: verbose)
    end

    def indent(text, num_spaces)
      text.gsub(/^/, 1.upto(num_spaces).map { |n| " " }.join)
    end
  end
end
