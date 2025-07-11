
# Test minerr_log ---------------------------------------------------------
# Because the tests runs in a clean environment, so this is expected to return error because there'll be no log to return.
test_that("minerr_log returns error", {
  expect_error(
    object = minerr_log()
  )
})


# Test minerr -------------------------------------------------------------
# Since the function works with LLM and the return values are not predictable, at the moment not test will be made.
