require 'rails_magic_renamer/version'
require 'rails_magic_renamer/exceptions'
require 'active_support/inflector'
require 'active_support/core_ext/string/inflections'

module RailsMagicRenamer

  # called from rails console: RailsMagicRenamer::Renamer.new("ModelOne", "ModelTwo").rename
  class Renamer
    def initialize(from, to)
      from = from.to_s if !from.class != String
      to = to.to_s if !to.class != String
      @from, @to = from, to
      begin
        valid_renamer?
      rescue RenamerError => e
        raise RailsMagicRenamer::InvalidObjectError.new(e.message)
      end
    end


    # check that models can be renamed
    def valid_renamer?
      raise RailsMagicRenamer::RenameObjectUnderscoredError.new if renamer_contains_underscores?
      raise RailsMagicRenamer::RenameFromObjectDoesNotExistError.new if !from_exists?
      raise RailsMagicRenamer::RenameToObjectExistsError.new if to_exists?
      # raise RailsMagicRenamer::RootDirectoryError.new if !in_root_directory?
      return true
    end

    def renamer_contains_underscores?
      @from.match("_") || @to.match("_")
    end

    def from_exists?
      return Object.const_get(@from) rescue false
    end

    def to_exists?
      return Object.const_get(@to) rescue false
    end

    def in_root_directory?
      File.exist?('./config/environment.rb')
    end

    # one entry point
    def rename
      model_rename
      controller_rename
    end

    def model_rename
      to_model_file = @to.underscore + ".rb"
      `mv app/models/#{@from.underscore}.rb app/models/#{to_model_file}`
      replace_in_file("app/models/#{to_model_file}", @from, @to)

      to_spec_file = @to.underscore + "_spec.rb"
      `mv spec/models/#{@from.underscore}_spec.rb spec/models/#{to_spec_file}`
      replace_in_file("spec/models/#{to_spec_file}", @from, @to)

      Dir["db/migrate/*_create_#{@from.underscore.pluralize}.rb"].each do |file|
        timestamp_and_path = file.split('_')[0]
        to_migration_path = "#{timestamp_and_path}_create_#{@to.underscore.pluralize}.rb"
        `mv #{file} #{to_migration_path}`
        replace_in_file(to_migration_path, "Create#{@from.pluralize}", "Create#{@to.pluralize}")
        replace_in_file(to_migration_path, @from.underscore.pluralize, @to.underscore.pluralize)
      end
    end

    def controller_rename
      setup_for_controller_rename

      to_controller_path = "app/controllers/#{@to.underscore}.rb"
      to_resource_name   = @to.gsub(/Controller$/, "")
      to_resource_path   = to_resource_name.underscore

      `mv app/controllers/#{@from.underscore}.rb #{to_controller_path}`
      replace_in_file(to_controller_path, @from, @to)

      # TODO: Use cross-platform move commands.
      if File.exist?("spec/controllers/#{@from.underscore}_spec.rb")
        to_spec = "spec/controllers/#{to_resource_path}_controller_spec.rb"
        `mv spec/controllers/#{@from.underscore}_spec.rb #{to_spec}`
        replace_in_file(to_spec, @from, @to)
      end

      if Dir.exist?("app/views/#{@from_resource_path}")
        `mv app/views/#{@from_resource_path} app/views/#{to_resource_path}`
      end

      to_helper_path = "app/helpers/#{to_resource_path}_helper.rb"
      if File.exist?("app/helpers/#{@from_resource_path}_helper.rb")
        `mv app/helpers/#{@from_resource_path}_helper.rb #{to_helper_path}`
        replace_in_file(to_helper_path, @from_resource_name, to_resource_name)
      end

      replace_in_file('config/routes.rb', @from_resource_path, to_resource_path)
    end

    def setup_for_controller_rename
      @from_controller, @from_action = @from.split(".")
      @from_resource_name = @from_controller.gsub(/Controller$/, "")
      @from_resource_path = @from_resource_name.underscore
    end

    def replace_in_file(path, find, replace)
      contents = File.read(path)
      contents.gsub!(find, replace)
      File.open(path, "w+") { |f| f.write(contents) }
    end
  end
end
