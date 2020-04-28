module Helpers
  module ReloadFiles
    def reload(file_path)
      original_verbose = $VERBOSE
      $VERBOSE = nil

      load "#{Rails.root}/../../#{file_path}.rb"

      $VERBOSE = original_verbose
    end
  end
end
