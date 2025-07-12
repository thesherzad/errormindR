
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
#' @param paren.frame environment, parent context. Not needed to provide any value.
#' @param chat character, user input
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
#' }
minerr <- function(paren.frame = parent.frame(),
                   chat = NULL,
                   share_full_context = TRUE,
                   llm_func = purrr::partial(ellmer::chat_openai, model = "gpt-4.1"),
                   insert_code = TRUE){

  stopifnot(is.null(chat) | is.character(chat))
  stopifnot(is.logical(share_full_context))
  stopifnot(is.logical(insert_code))
  stopifnot(is.function(llm_func))

  tryCatch({
    # log the error
    capture_error(paren.frame)
  }, finally = {
    sys_prompt <- build_prompt(share_full_context)

    # LLM call
    llm <- llm_func(
      system_prompt = sys_prompt
    )

    .chat <- build_chat(chat)

    llm_resp <- llm$chat(
      .chat
    ) |> invisible()

    # log the chat
    if(length(llm_resp) > 0){
      create_chat_log(llm_resp)
    }

    # clean and insert the code into editor
    if(isTRUE(insert_code)){
      gsub("```r\\s*|```", "", llm_resp) |>
        glue::glue("\n\n") |>
        rstudioapi::insertText()
    }
  })
}
