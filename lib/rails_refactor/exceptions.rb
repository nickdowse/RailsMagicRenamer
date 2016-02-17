module RailsRefactor

  class RefactorError < StandardError;
  end

  class InvalidObjectError < RefactorError
    def initialize(message = "The object you are trying to rename is invalid.")
      super(message)
    end
  end

  class RenameToObjectExistsError < RefactorError
    def initialize(message = "The object you are trying to rename to already exists.")
      super(message)
    end
  end

  class RenameFromObjectDoesNotExistError < RefactorError
    def initialize(message = "The object you are trying to rename from does not exist.")
      super(message)
    end
  end

  class RootDirectoryError < RefactorError
    def initialize(message = "RailsRefactor must be run from your root directory.")
      super(message)
    end
  end
end
