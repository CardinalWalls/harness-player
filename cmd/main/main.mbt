///|
/// Runnable entrypoint for the current proof slice.
fn main {
  let argv = @env.args()
  let config = @lib.parse_surface_config(argv[1:]) catch {
    _ => @lib.default_surface_config()
  }
  println(@lib.thin_surface_report(config))
}
