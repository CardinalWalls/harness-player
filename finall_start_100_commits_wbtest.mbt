///|
test "runtime contract is not empty" {
  assert_eq(runtime_contract().length() > 0, true)
}
