///|
test "route_input preserves targeted control commands" {
  let command = @control.route_input(
    @control.session_target("exec-1"),
    "raise exploration budget",
    10,
  )

  inspect(@control.command_is_targeted(command), content="true")
  inspect(@control.command_body(command), content="raise exploration budget")
}

///|
test "route_input supports projection targets without runtime role leakage" {
  let command = @control.route_input(
    @control.projection_target("story-lane"),
    "focus on chapter boundaries",
    5,
  )

  inspect(@control.command_is_targeted(command), content="true")
  inspect(@control.command_body(command), content="focus on chapter boundaries")
}
