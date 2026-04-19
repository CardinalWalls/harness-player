///|
/// Runnable entrypoint for the current proof slice.
fn artifact_root_dir() -> String {
  "artifacts"
}

///|
fn materialized_export_dir() -> String {
  "\{artifact_root_dir()}/materialized-exports"
}

///|
fn ensure_directory(path : String) -> Unit {
  let exists = @fs.is_dir(path) catch { _ => false }
  if !exists {
    try! @fs.create_dir(path)
  }
}

///|
fn candidate_export_path(file_name : String, attempt : Int) -> String {
  let base_path = "\{materialized_export_dir()}/\{file_name}"
  if attempt == 0 {
    base_path
  } else {
    "\{base_path}.\{attempt}"
  }
}

///|
fn next_available_export_path(file_name : String, attempt : Int) -> String {
  let candidate = candidate_export_path(file_name, attempt)
  let occupied = @fs.is_file(candidate) catch { _ => false }
  if occupied {
    next_available_export_path(file_name, attempt + 1)
  } else {
    candidate
  }
}

///|
fn main {
  let argv = @env.args()
  let config = @lib.parse_surface_config(argv[1:]) catch {
    _ => @lib.default_surface_config()
  }
  let report = @lib.surface_report(config)
  if @lib.should_write_materialized_export(config) {
    ensure_directory(artifact_root_dir())
    ensure_directory(materialized_export_dir())
    let output_path = next_available_export_path(
      @lib.materialized_export_file_name(config),
      0,
    )
    let persisted = @lib.planned_materialized_export(output_path, config)
    try! @fs.write_string_to_file(
      persisted.output_path,
      persisted.report_body,
      encoding="utf8",
    )
    println(
      "\{report}\npersisted=\{@lib.persisted_materialized_export_key(persisted)}",
    )
  } else {
    println(report)
  }
}
