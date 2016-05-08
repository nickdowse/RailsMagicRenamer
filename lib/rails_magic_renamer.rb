require 'rails_magic_renamer/version'
require 'rails_magic_renamer/exceptions'
require 'active_support/inflector'
require 'active_support/core_ext/string/inflections'

module RailsMagicRenamer

  # called from rails console: RailsMagicRenamer::Renamer.new("ModelOne", "ModelTwo").rename
  class Renamer

    @@timestamp

    def initialize(from, to)
      from = from.to_s if !from.class != String
      to = to.to_s if !to.class != String
      @from, @to = from, to
      FileUtils.cd('spec/support/sample_app_rails_4') if File.exist?('rails_magic_renamer.gemspec')
      Rails.application.eager_load!

      @@timestamp = Time.now.strftime("%Y%m%d%H%M%S").to_i
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

    # only entry point
    def rename
      Rails.application.eager_load!
      @from = Object.const_get(@from)
      @to = Object.const_set(@to, Class.new)
      # here prevent factory girl from linting factories
      if !Dir.glob('**/factory_girl.rb').empty?
        file = Dir.glob('**/factory_girl.rb').first
        replace_in_file(file, "FactoryGirl.lint", "# FactoryGirl.lint")
      end
      rename_models
      rename_controllers
      rename_views
      rename_helpers
      rename_routes
      rename_specs
      rename_assets
      rename_everything_else
    end

    def rename_models
      # commit any changes to git if is uncommitted and git is installed
      `git add -A && git commit -m "Code before RailsMagicRenamer renaming"` if !`git status | grep "On branch"`.empty? && !in_test_mode?
      to_model_file = @to.to_s.underscore + ".rb"

      rename_relations

      # move model file
      `mv app/models/#{@from.to_s.underscore}.rb app/models/#{to_model_file}` # here test for success?
      
      # move model container file (eg app/models/companies/*.rb)
      if File.directory?(@from.to_s.underscore)
        `mv app/models/#{@from.to_s.underscore} app/models/#{@to.to_s.underscore}`
      end

      replace("app/models/#{to_model_file}")

    end

    def rename_relations
      relations = @from.reflect_on_all_associations
      relations.each do |relation|
        if File.exist?("app/models/#{relation.name}.rb")
          replace("app/models/#{relation.name}.rb")
        elsif relation.class_name.to_s.underscore != relation.name.to_s && File.exist?("app/models/#{relation.class_name.to_s.underscore}.rb")
          replace("app/models/#{relation.class_name.to_s.underscore}.rb")
        end
        if relation.macro == :belongs_to
          puts "Relation macro #{relation.name} is a belongs_to updating the foreign key here"
        elsif relation.macro == :has_many
          puts "Relation macro #{relation.name} is a has_many updating the foreign key here"
          if !relation.options.has_key?(:through)
            # renaming the through relationship here
            # if relation is UserComment etc (eg a join table)
            if relation.class_name.to_s.match(@from.to_s) && File.exist?("app/models/#{relation.class_name.underscore}.rb")
              # here rename UserComment class name to PosterComment: UserComment -> PosterComment
              replace_in_file("app/models/#{relation.class_name.underscore}.rb", relation.class_name, relation.class_name.to_s.gsub(@from.to_s.pluralize, @to.to_s.pluralize).gsub(@from.to_s, @to.to_s))
              # move user_comment.rb -> poster_comment.rb
              `mv "app/models/#{relation.class_name.underscore}.rb" app/models/#{relation.class_name.underscore.gsub(@from.to_s.underscore.pluralize, @to.to_s.underscore.pluralize).gsub(@from.to_s.underscore, @to.to_s.underscore)}.rb`
              # Replace user_comments with poster_comments everywhere it might be used:
              rename_in_app_lib_rake_spec(relation.name.to_s, relation.name.to_s.gsub(@from.to_s.underscore.pluralize, @to.to_s.underscore.pluralize).gsub(@from.to_s.underscore, @to.to_s.underscore))
              # here create migration to rename table
              if Object.const_defined?(relation.class_name) && Object.const_get(relation.class_name).column_names.include?("#{@from.to_s.underscore}_id")
                generate_rename_column_migration(relation, "#{@from.to_s.underscore}_id")
              end
              generate_rename_table_migration_from_relation(relation)
            else
              # here create a migration to rename user_id if user_id exists
              if Object.const_defined?(relation.class_name) && Object.const_get(relation.class_name).column_names.include?("#{@from.to_s.underscore}_id")
                generate_rename_column_migration(relation, "#{@from.to_s.underscore}_id")
              end
            end
          else
            # renaming the actual relationship here
            puts "Has many, through #{relation.options[:through]}"
            if File.exist?("app/models/#{relation.class_name.underscore}.rb")
              # replace user_comments -> poster_comments in comments.rb
              replace_in_file("app/models/#{relation.class_name.underscore}.rb", relation.options[:through].to_s, relation.options[:through].to_s.gsub(@from.to_s.underscore, @to.to_s.underscore))
            elsif relation.options[:through].present? && File.exist?("app/models/#{relation.options[:through].to_s.underscore.singularize}.rb")
              replace_in_file("app/models/#{relation.options[:through].to_s.singularize}.rb", relation.options[:through].to_s, relation.options[:through].to_s.gsub(@from.to_s.underscore, @to.to_s.underscore))
            end

            # replace followed_users -> followed_posters in user.rb
            replace_in_file("app/models/#{@from.to_s.underscore}.rb", relation.name.to_s, relation.name.to_s.gsub(@from.to_s.underscore, @to.to_s.underscore))
            # replace followed_users -> followed_posters in the rest of the app
            rename_in_app_lib_rake_spec(relation.name.to_s, relation.name.to_s.gsub(@from.to_s.underscore.pluralize, @to.to_s.underscore.pluralize).gsub(@from.to_s.underscore, @to.to_s.underscore))
            # move user_comments_spec.rb to poster_comments_spec.rb
            if File.exist?("spec/models/#{relation.name.to_s.underscore}_spec.rb")
              `mv "spec/models/#{relation.name.to_s.underscore}_spec.rb" spec/models/#{relation.name.to_s.gsub(@from.to_s.underscore.pluralize, @to.to_s.underscore.pluralize).gsub(@from.to_s.underscore, @to.to_s.underscore)}_spec.rb`
            end
          end
        else
          puts "Why in here? #{relation.macro}"
          puts "#{relation.macro} type relationships are not supported to be renamed right now."
          # could be a has_one relationship?
        end
      end
      generate_rename_table_migration(@from.table_name, @to.to_s.underscore.pluralize)
    end

    def generate_rename_table_migration_from_relation(relation)
      class_name = "Rename#{relation.class_name}"
      file_contents = "class #{class_name} < ActiveRecord::Migration
  def change
    rename_table :#{relation.plural_name}, :#{relation.plural_name.to_s.gsub(@from.to_s.underscore, @to.to_s.underscore)}
  end
end
"
      File.open("db/migrate/#{@@timestamp}_#{class_name.underscore}.rb", 'w') {|f| f.write(file_contents) }
      @@timestamp = @@timestamp + 1
    end

    def generate_rename_column_migration(relation, column_name)
      class_name = "Rename#{relation.class_name}#{column_name.camelize}"
      file_contents = "class #{class_name} < ActiveRecord::Migration
  def change
    rename_column :#{relation.plural_name}, :#{column_name}, :#{column_name.gsub(@from.to_s.underscore, @to.to_s.underscore)}
  end
end
"
      File.open("db/migrate/#{@@timestamp}_#{class_name.underscore}.rb", 'w') {|f| f.write(file_contents) }
      @@timestamp = @@timestamp + 1
    end

    def generate_rename_table_migration(from, to)
      class_name = "Rename#{from.capitalize}To#{to.capitalize}"
      file_contents = "class #{class_name} < ActiveRecord::Migration
  def change
    rename_table :#{from}, :#{to}
  end
end
"
      File.open("db/migrate/#{@@timestamp}_#{class_name.underscore}.rb", 'w') {|f| f.write(file_contents) }
      @@timestamp = @@timestamp + 1
    end

    def rename_controllers
      to_controller_path = "app/controllers/#{@to.to_s.underscore.pluralize}_controller.rb"
      `mv app/controllers/#{@from.to_s.underscore.pluralize}_controller.rb #{to_controller_path}`
      replace(to_controller_path)
      replace_in_file(to_controller_path, "#{@from.to_s.pluralize}Controller", "#{@to.to_s.pluralize}Controller")
    end

    def rename_views
      `mv app/views/#{@from.to_s.underscore.pluralize} app/views/#{@to.to_s.underscore.pluralize}` # here test for success?
      if !Dir.glob("app/views/#{@to.to_s.underscore.pluralize}/_#{@from.to_s.pluralize.underscore}.*").empty?
        Dir.glob("app/views/#{@to.to_s.underscore.pluralize}/_#{@from.to_s.pluralize.underscore}.*") do |partial|
          subbed_partial = partial.gsub(@from.to_s.underscore.pluralize, @to.to_s.underscore.pluralize).gsub(@from.to_s.underscore, @to.to_s.underscore)
          `mv #{partial} #{subbed_partial}`
        end
      end

      if !Dir.glob("app/views/#{@to.to_s.underscore.pluralize}/_#{@from.to_s.underscore}.*").empty?
        Dir.glob("app/views/#{@to.to_s.underscore.pluralize}/_#{@from.to_s.underscore}.*") do |partial|
          subbed_partial = partial.gsub(@from.to_s.underscore.pluralize, @to.to_s.underscore.pluralize).gsub(@from.to_s.underscore, @to.to_s.underscore)
          `mv #{partial} #{subbed_partial}`
        end
      end
    end

    def rename_helpers
      to_helper_path = "app/helpers/#{@to.to_s.underscore.pluralize}_helper.rb"
      if File.exist?("app/helpers/#{@from.to_s.underscore.pluralize}_helper.rb")
        `mv app/helpers/#{@from.to_s.underscore.pluralize}_helper.rb #{to_helper_path}`
        replace(to_helper_path)
        replace_in_file(to_helper_path, "#{@from.to_s.pluralize}Helper", "#{@to.to_s.pluralize}Helper")
      end
    end

    def rename_routes
      rake_routes_output = `rake routes | grep #{@from.to_s.underscore}`
      split_output = rake_routes_output.split(/GET|POST|PATCH|PUT|DELETE|\n/).delete_if{|w| w.match("/")}.map(&:strip!)
      split_output.each do |path|
        rename_path(path + "_path")
        rename_path(path + "_url")
      end
      replace('config/routes.rb')
    end

    def rename_specs
      # controller
      if File.exist?("spec/controllers/#{@from.to_s.underscore.pluralize}_controller_spec.rb")
        to_spec = "spec/controllers/#{@to.to_s.underscore.pluralize}_controller_spec.rb"
        `mv spec/controllers/#{@from.to_s.underscore.pluralize}_controller_spec.rb #{to_spec}`
        replace(to_spec)
      end
      # features
      if File.exist?("spec/features/#{@from.to_s.underscore}_pages_spec.rb")
        to_spec = "spec/features/#{@to.to_s.underscore}_pages_spec.rb"
        `mv spec/features/#{@from.to_s.underscore}_pages_spec.rb #{to_spec}`
        replace(to_spec)
      end
      # helpers
      if File.exist?("spec/helpers/#{@from.to_s.underscore.pluralize}_helper_spec.rb")
        to_spec = "spec/helpers/#{@to.to_s.underscore.pluralize}_helper_spec.rb"
        `mv spec/helpers/#{@from.to_s.underscore.pluralize}_helper_spec.rb #{to_spec}`
        replace(to_spec)
      end
      # models
      if File.exist?("spec/models/#{@from.to_s.underscore}_spec.rb")
        to_spec = "spec/models/#{@to.to_s.underscore}_spec.rb"
        `mv spec/models/#{@from.to_s.underscore}_spec.rb #{to_spec}`
        replace(to_spec)
      end
    end

    def rename_path(path_to_rename)
      return if path_to_rename == "_url" || path_to_rename == "_path"
      renamed_path = path_to_rename.gsub(@from.to_s.underscore, @to.to_s.underscore).gsub(@from.to_s.underscore.pluralize, @to.to_s.underscore.pluralize)
      Dir.glob("app/**/*") do |app_file|
        next if File.directory?(app_file)
        replace_in_file(app_file, path_to_rename, renamed_path)
      end

      Dir.glob("spec/**/*") do |spec_file|
        next if File.directory?(spec_file)
        replace_in_file(spec_file, path_to_rename, renamed_path)
      end
    end

    def rename_assets
      Dir.glob("app/assets/**/*#{@from.to_s.underscore.pluralize}*") do |asset_file|
        puts "Asset file: #{asset_file}"
        puts "Asset file: #{asset_file.to_s.gsub(@from.to_s.underscore.pluralize, @to.to_s.underscore.pluralize)}"
        `mv #{asset_file} #{asset_file.to_s.gsub(@from.to_s.underscore.pluralize, @to.to_s.underscore.pluralize)}`
      end
      Dir.glob("app/assets/**/*#{@from.to_s.underscore}*") do |asset_file|
        puts "Asset file: #{asset_file}"
        puts "Asset file: #{asset_file.to_s.gsub(@from.to_s.underscore, @to.to_s.underscore)}"
        `mv #{asset_file} #{asset_file.to_s.gsub(@from.to_s.underscore, @to.to_s.underscore)}`
      end
    end

    # here pass every file in the app folder, lib folder, spec folder through the renamer
    def rename_everything_else
      Dir.glob("app/**/*") do |app_file|
        next if File.directory?(app_file) || !text?(app_file)
        replace(app_file)
      end

      Dir.glob("lib/**/*.rb") do |lib_file|
        replace(lib_file)
      end

      Dir.glob("**/*.rake") do |rake_file|
        replace(rake_file)
      end

      Dir.glob("spec/**/*.rb") do |spec_file|
        replace(spec_file)
      end
    end

    def rename_in_app_lib_rake_spec(find, replace)
      Dir.glob("app/**/*") do |app_file|
        next if File.directory?(app_file) || !text?(app_file)
        replace_in_file(app_file, find, replace)
      end

      Dir.glob("lib/**/*.rb") do |lib_file|
        replace_in_file(lib_file, find, replace)
      end

      Dir.glob("**/*.rake") do |rake_file|
        replace_in_file(rake_file, find, replace)
      end

      Dir.glob("spec/**/*.rb") do |spec_file|
        replace_in_file(spec_file, find, replace)
      end
    end

    def replace(file_name)
      replace_in_file(file_name, @from.to_s, @to.to_s)
      replace_in_file(file_name, @from.to_s.underscore, @to.to_s.underscore)
    end

    def replace_in_file(path, find, replace)
      return false if !File.exist?(path)
      contents = File.read(path)
      contents = contents.unpack('C*').pack('U*') if !contents.valid_encoding?
      replaced_contents = contents.gsub(/\b#{Regexp.escape(find)}\b/, replace).gsub(/\b#{Regexp.escape("#{find}s")}\b/, "#{replace}s").gsub(/\b#{Regexp.escape("#{find}_id")}\b/, "#{replace}_id")
      File.open(path, "w+") { |f| f.write(replaced_contents) }
    end

    def in_test_mode?
      return @in_test_mode if @in_test_mode.present?
      @in_test_mode = File.exist?('./rails_magic_renamer.gemspec') || File.exist?('../../../rails_magic_renamer.gemspec')
      return @in_test_mode
    end

    def text?(filename)
      begin
        fm = FileMagic.new(FileMagic::MAGIC_MIME)
        fm.file(filename) =~ /^text\//
      ensure
        fm.close
      end
    end

    def binary?(filename)
      !text?
    end
  end
end
