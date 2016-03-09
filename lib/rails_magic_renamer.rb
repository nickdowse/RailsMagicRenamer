require 'rails_magic_renamer/version'
require 'rails_magic_renamer/exceptions'
require 'active_support/inflector'
require 'active_support/core_ext/string/inflections'

module RailsMagicRenamer

  # called from rails console: RailsMagicRenamer::Renamer.new(ModelOne, ModelTwo).rename
  class Renamer
    def initialize(from, to)
      from = from.to_s if !from.class != String
      to = to.to_s if !to.class != String
      @from, @to = from, to
      Rails.application.eager_load!
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
      return Object.const_defined?("#{@from}")
    end

    def to_exists?
      return Object.const_defined?(@to)
    end

    def in_root_directory?
      File.exist?('./config/environment.rb')
    end

    # one entry point
    def rename
      Rails.application.eager_load!
      @from = Object.const_get(@from)
      @to = Object.const_set(@to, Class.new)
      model_rename
      # controller_rename
    end

    def model_rename
      # commit any changes to git if is uncommitted and git is installed
      `git add -A && git commit -m "Code before RailsMagicRenamer renaming"` if !`git status | grep "On branch"`.empty?
      to_model_file = @to.to_s.underscore + ".rb"

      rename_relations
      rename_descendants
      

      # move model file
      puts "Pathname exists?"
      puts Pathname.new("app/models/#{@from.to_s.underscore}.rb").exists?
      puts `ls . | grep rails_magic_renamer`.present?
      `mv app/models/#{@from.to_s.underscore}.rb app/models/#{to_model_file}` # here test for success?
      # move model container file (eg app/models/companies/*.rb)
      `mv app/models/#{@from.to_s.underscore} app/models/#{@to.to_s.underscore}`

      replace_in_file("app/models/#{to_model_file}", @from.to_s, @to.to_s)

    end

    def rename_relations
      relations = @from.reflect_on_all_associations
      # each relation...
      # check whether there is a file where we expect it to be (eg app/models/#{relation.name.to_s.singularize}.rb)
      # if so, find and replace the @from in that file
      # if not, check if the class name specified is different.
      # if the class name is different, then get that, underscore it, and try that file.
      # if it exists, replace replace replace!
      puts "Renaming relations!"
      puts relations.to_yaml
      relations.each do |relation|
        puts "=================="
        puts relation.to_yaml
        puts "==================="
      end
    end

    def rename_descendants
      descendants = @from.descendants.map{|d| d.to_s}.sort
      # for each descendant loop through
      # check whether there is a file where we expect it to be (eg app/models/#{relation.name.to_s.singularize}.rb)
      # if so replace in file
      # rename file if it matches the rename criteria
      descendants.each do |descendant|

      end
    end


    # def controller_rename
    #   setup_for_controller_rename

    #   to_controller_path = "app/controllers/#{@to.underscore}.rb"
    #   to_resource_name   = @to.gsub(/Controller$/, "")
    #   to_resource_path   = to_resource_name.underscore

    #   `mv app/controllers/#{@from.underscore}.rb #{to_controller_path}`
    #   replace_in_file(to_controller_path, @from, @to)

    #   # TODO: Use cross-platform move commands.
    #   if File.exist?("spec/controllers/#{@from.underscore}_spec.rb")
    #     to_spec = "spec/controllers/#{to_resource_path}_controller_spec.rb"
    #     `mv spec/controllers/#{@from.underscore}_spec.rb #{to_spec}`
    #     replace_in_file(to_spec, @from, @to)
    #   end

    #   if Dir.exist?("app/views/#{@from_resource_path}")
    #     `mv app/views/#{@from_resource_path} app/views/#{to_resource_path}`
    #   end

    #   to_helper_path = "app/helpers/#{to_resource_path}_helper.rb"
    #   if File.exist?("app/helpers/#{@from_resource_path}_helper.rb")
    #     `mv app/helpers/#{@from_resource_path}_helper.rb #{to_helper_path}`
    #     replace_in_file(to_helper_path, @from_resource_name, to_resource_name)
    #   end

    #   replace_in_file('config/routes.rb', @from_resource_path, to_resource_path)
    # end

    # def setup_for_controller_rename
    #   @from_controller, @from_action = @from.split(".")
    #   @from_resource_name = @from_controller.gsub(/Controller$/, "")
    #   @from_resource_path = @from_resource_name.underscore
    # end

    def replace_in_file(path, find, replace)
      contents = File.read(path)
      contents.gsub!(find, replace)
      File.open(path, "w+") { |f| f.write(contents) }
    end
  end
end
