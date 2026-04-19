///|
pub(all) suberror IOError {
  IOError(String)
} derive(Debug)

///|
pub impl Show for IOError with output(self : IOError, logger : &Logger) -> Unit {
  match self {
    IOError(message) => {
      logger.write_string("IOError(")
      logger.write_object(message)
      logger.write_char(')')
    }
  }
}

///|
#deprecated("Use `Debug` via `@debug.to_repr` / `@debug.render` instead", skip_current_package=true)
pub impl Show for IOError

///|
pub fn write_string_to_file(
  path : String,
  content : String,
  encoding? : String = "utf8",
) -> Unit raise IOError {
  write_string_to_file_internal(path, content, encoding~)
}

///|
pub fn create_dir(path : String) -> Unit raise IOError {
  create_dir_internal(path)
}

///|
pub fn is_dir(path : String) -> Bool raise IOError {
  is_dir_internal(path)
}

///|
pub fn is_file(path : String) -> Bool raise IOError {
  is_file_internal(path)
}
