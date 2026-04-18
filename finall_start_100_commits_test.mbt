///|
test "runtime contract string is stable" {
  inspect(
    @finall_start_100_commits.runtime_contract(),
    content="OMX orchestrates; MoonBit validates.",
  )
}
