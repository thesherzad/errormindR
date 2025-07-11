
# Test get_log_dir --------------------------------------------------------

test_that("check return type", {
  expect_type(
    object = get_log_dir(),
    type = "character"
  )
})

test_that("check it returns a path", {
  expect_true(
    object = fs::is_dir(get_log_dir())
  )
})
