module RailsMagicRenamer

  class RenamerError < StandardError;
  end

  class InvalidObjectError < RenamerError
    def initialize(message = "The object you are trying to rename is invalid.")
      super(message)
    end
  end

  class RenameObjectUnderscoredError < RenamerError
    def initialize(message = "The object you are trying to rename to or from contains underscores. Your models must be formatted in CamelCase (eg MyModel).")
      super(message)
    end
  end

  class RenameToObjectExistsError < RenamerError
    def initialize(message = "The object you are trying to rename to already exists.")
      super(message)
    end
  end

  class RenameFromObjectDoesNotExistError < RenamerError
    def initialize(message = "The object you are trying to rename from does not exist.")
      super(message)
    end
  end

  class RootDirectoryError < RenamerError
    def initialize(message = "RailsMagicRenamer must be run from your root directory.")
      super(message)
    end
  end
end
