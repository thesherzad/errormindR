
# check if the given code is really a `call` object
check_expr <- function(.expr){
  tryCatch({
    result <- eval(.expr, envir = parent.frame())

    if (inherits(result, "ggplot") || inherits(result, "recordedplot") || is.language(result)) {
      invisible(print(result))
    }

    if (is.function(result)) {
      invisible(force(result()))
    }

    return(TRUE)
  }, error = function(e) {
    invisible(return(structure(list(error = e), class = "captured_error")))
  })
}

# collect context; code up to the error point
get_editor_content <- function(share_full_context = TRUE){
  file_name <- paste("File name:", basename(rstudioapi::getSourceEditorContext()$path))

  runtime <- paste("Run time:", Sys.time())

  src_code <- NULL
  if(isTRUE(share_full_context)){
    doc <- rstudioapi::getActiveDocumentContext()
    src_code <- glue::glue_collapse(doc$contents[1:(doc$selection[[1]]$range$start["row"] - 1)], sep = "\n")
  }

  context <- list(
    file_name = file_name,
    runtime = runtime,
    src_code = src_code
  )

  context
}

# prepare prompt for LLM
build_prompt <- function(share_full_context = TRUE){
  stopifnot(is.logical(share_full_context))

  prompt_path <- system.file("prompt", "prompt.md", package = "errormindR")
  if(!file.exists(prompt_path)){
    stop("Prompt not found")
  }
  prompt_content <- readLines(prompt_path, warn = FALSE)
  prompt_text <- paste(prompt_content, collapse = "\n")


  error_context <- get_editor_content(share_full_context)$src_code
  if(length(error_context) < 1){
    message("No context found!")
  }

  # stick the dynamic content to prompt
  whisker::whisker.render(
    prompt_text,
    list(
      error_context = error_context
    )
  )

}

# create chat content for LLM; in case user provided additional context
build_chat <- function(error_msg, user_chat = NULL){
  if(inherits(error_msg, "captured_error")){
    error_msg <- paste0("Error [", class(error_msg)[1], "]: ", error_msg$error)
  }

  if(length(error_msg) < 1){
    warning("No error found to debug")
  }
  # add user input if provided
  chat <- if(is.null(user_chat)) "Help me to debug below R code: \n" else paste0(user_chat, "\n")
  glue::glue("<<<chat>>>\n<<<error_msg>>>", .open = "<<<", .close = ">>>")
}

# create a log of this conversation with LLM
create_chat_log <- function(llm_resp, req_to_llm){
  glue::glue(
    "<<<get_editor_content()$file_name>>>\n\n",
    "<<<get_editor_content()$runtime>>>\n\n",
    "Request to LLM: \n<<<req_to_llm>>>\n\n",
    "LLM's Reponse: \n<<<llm_resp>>>",
    .open = "<<<", .close = ">>>"
  ) |>
    writeLines(con = file.path(get_log_dir(), "last_chat_log.txt"), sep = "\n")
}

# return last log's path
get_last_log_path <- function(){
  log_path <- file.path(get_log_dir(), "last_chat_log.txt")
  if(!file.exists(log_path)){
    stop("Logs not found")
  }
  log_path
}

# create and return temporary directory for saving temporary logs
get_log_dir <- function(){
  log_dir <- file.path(tempdir(), "errormindR_logs")
  if (!dir.exists(log_dir)) dir.create(log_dir, recursive = TRUE)
  log_dir
}
