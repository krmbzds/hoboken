module Hoboken
  class Generate < Thor::Group
    include Thor::Actions

    argument :name

    class_option :ruby_version,
                 type: :string,
                 desc: "Ruby version for Gemfile",
                 default: RUBY_VERSION

    class_option :tiny,
                 type: :boolean,
                 desc: "Generate views inline; do not create /public folder",
                 default: false

    class_option :type,
                 type: :string,
                 desc: "Architecture type (classic or modular)",
                 default: :classic

    def self.source_root
      File.dirname(__FILE__)
    end

    def app_folder
      empty_directory(snake_name)
      apply_template("classic.rb.tt",  "app.rb")
      apply_template("Gemfile.erb.tt", "Gemfile")
      apply_template("config.ru.tt",   "config.ru")
      apply_template("README.md.tt",   "README.md")
      apply_template("Rakefile.tt",    "Rakefile")
    end

    def view_folder
      empty_directory("#{snake_name}/views")
      apply_template("views/layout.erb.tt", "views/layout.erb")
      apply_template("views/index.erb.tt", "views/index.erb")
    end

    def inline_views
      return unless options[:tiny]
      combined_views = %w(layout index).map do |f|
        "@@#{f}\n" + File.read("#{snake_name}/views/#{f}.erb")
      end.join("\n")

      append_to_file("#{snake_name}/app.rb", "\n__END__\n\n#{combined_views}")
      remove_dir("#{snake_name}/views")
    end

    def public_folder
      return if options[:tiny]
      inside snake_name do
        empty_directory("public")
        %w(css img js).each { |f| empty_directory("public/#{f}") }
      end
    end

    def test_folder
      empty_directory("#{snake_name}/test/unit")
      empty_directory("#{snake_name}/test/support")
      apply_template("test/unit/test_helper.rb.tt", "test/unit/test_helper.rb")
      apply_template("test/unit/app_test.rb.tt", "test/unit/app_test.rb")
      apply_template("test/support/rack_test_assertions.rb.tt", "test/support/rack_test_assertions.rb")
    end

    def make_modular
      return unless "modular" == options[:type]
      remove_file("#{snake_name}/app.rb")
      apply_template("modular.rb.tt", "app.rb")
      ["config.ru", "test/unit/test_helper.rb"].each do |f|
        path = File.join(snake_name, f)
        gsub_file(path, /Sinatra::Application/, "#{camel_name}::App")
      end
    end

    def directions
      say "\nSuccessfully created #{name}. Don't forget to `bundle install`"
    end

    private

    def snake_name
      Thor::Util.snake_case(name)
    end

    def camel_name
      Thor::Util.camel_case(name)
    end

    def titleized_name
      snake_name.split("_").map(&:capitalize).join(" ")
    end

    def author
      `git config user.name`.chomp
    end

    def apply_template(src, dest)
      template("templates/#{src}", "#{snake_name}/#{dest}")
    end
  end
end