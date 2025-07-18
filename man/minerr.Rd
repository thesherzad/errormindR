% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/minerr.R
\name{minerr}
\alias{minerr}
\title{Using AI/LLM analyzes the given error and offers solution}
\usage{
minerr(
  .expr,
  chat = NULL,
  is_logical_error = FALSE,
  share_full_context = TRUE,
  llm_func = purrr::partial(ellmer::chat_openai, model = "gpt-4.1"),
  insert_code = TRUE
)
}
\arguments{
\item{.expr}{expression, the code block that fails}

\item{chat}{character, user input/instructions to LLM. Required if \code{is_logical_error} is TRUE}

\item{is_logical_error}{logical, set to TRUE if it's a logical error}

\item{share_full_context}{logical, whether to share the context or not}

\item{llm_func}{function, preferred chat model. default it openai.}

\item{insert_code}{logical, whether to insert code in the editor or not}
}
\value{
LLM's response, both in the console and inserts into the editor
}
\description{
Using AI/LLM analyzes the given error and offers solution
}
\examples{
\dontrun{
library(data.table)
dt <- as.data.table(mtcars)
dt[, .(cnt = .N), by = .("cyl", "gear")] |> minerr()

x <- c(TRUE, FALSE)
minerr(
  if (x) {
    print("x is TRUE")
  }
)
}
}
