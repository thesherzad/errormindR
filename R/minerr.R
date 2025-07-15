
#' Either print or download the last log of the communication with AI
#'
#' @param download logical, if set to TRUE, it'll download the log file as .txt
#'
#' @returns character or a file, the log of the chat with AI
#' @export
#'
#' @examples
#' \dontrun{
#' minerr_log()
#' minerr_log(download = TRUE)
#' }
minerr_log <- function(download = FALSE){

  if(isTRUE(download)){
    destfile <- "errormindR_last_chat_log.txt"

    file.copy(get_last_log_path(), destfile, overwrite = TRUE)

    message("Log file copied to: ", normalizePath(destfile))
  }else{
    readLines(get_last_log_path()) |>
      glue::glue_collapse(sep = "\n")
  }

}

# NOTE: `minerr` name is referenced in the prompt.md file, if renamed, change it there too.
#' Using AI/LLM analyzes the given error and offers solution
#'
#' @param .expr expression, the code block that fails
#' @param chat character, user input/instructions to LLM. Required if `is_logical_error` is TRUE
#' @param is_logical_error logical, set to TRUE if it's a logical error
#' @param share_full_context logical, whether to share the context or not
#' @param llm_func function, preferred chat model. default it openai.
#' @param insert_code logical, whether to insert code in the editor or not
#'
#' @returns LLM's response, both in the console and inserts into the editor
#' @export
#'
#' @examples
#' \dontrun{
#' library(data.table)
#' dt <- as.data.table(mtcars)
#' dt[, .(cnt = .N), by = .("cyl", "gear")] |> minerr()
#'
#' x <- c(TRUE, FALSE)
#' minerr(
#'   if (x) {
#'     print("x is TRUE")
#'   }
#' )
#' }
minerr <- function(.expr,
                   chat = NULL,
                   is_logical_error = FALSE,
                   share_full_context = TRUE,
                   llm_func = purrr::partial(ellmer::chat_openai, model = "gpt-4.1"),
                   insert_code = TRUE){

  stopifnot(is.null(chat) | is.character(chat))
  stopifnot(is.logical(share_full_context))
  stopifnot(is.logical(insert_code))
  stopifnot(is.logical(is_logical_error))
  stopifnot(is.function(llm_func))
  assertthat::assert_that(
    rlang::is_call(
      substitute(.expr)
    ),
    msg = "`.expr` must be a `call` object; a chuck of code that intended to compute an input."
  )
  if(isTRUE(is_logical_error) && is.null(chat)) {
    stop("If `is_logical_error = TRUE`, the `chat` argument must be provided.")
  }

  if(isTRUE(is_logical_error)){
    eval_result <- "It's a logical error. User's input above."
  }else{
    eval_result <- check_expr(.expr)
  }

  if(!isTRUE(eval_result)){
    sys_prompt <- build_prompt(share_full_context)

    .chat <- build_chat(eval_result, chat)

    # LLM call
    llm <- llm_func(
      system_prompt = sys_prompt
    )

    llm_resp <- llm$chat(
      .chat
    ) |> invisible()

    # log the chat
    if(length(llm_resp) > 0){
      create_chat_log(llm_resp, .chat)
    }

    # clean and insert the code into editor
    if(isTRUE(insert_code)){
      invisible(
        gsub("```r\\s*|```", "", llm_resp) |>
          glue::glue("\n\n", .open = "<<<", .close = ">>>") |>
          rstudioapi::insertText()
      )
    }
  }else{
    message("The given code doesn't seem to return an error. Please try again with a code that fails.")
  }
}

