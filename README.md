
<!-- README.md is generated from README.Rmd. Please edit that file -->

# errormindR

<!-- badges: start -->
<!-- badges: end -->

## Disclaimer

This is a prove of concept package and contains only two functions. It’s
not recommended for production.

The goal of `errormindR` is to provide a friendly interface to
communicate with a AI/LLM to explain an error and provide a solution
right in the RStudio editor.

Not implemented now, but the ultimate goal of the package is to
automatically replaces the failing parts of a program. Think of this
that you’ve some programs that run based on schedule, but something
unexpected causes failure. This tool can be called (future versions) as
an extra layer of safety to debug the code, test the output against the
previous version and keep a log of these changes.

This package uses `ellmer` package behind the scene to communicate with
an LLM. The default model is “gpt-4o” from OpenAI, but you can provide
your own. Additionally, you may need to set up your API key if this is
your first time using LLM via API. Here’s a brief
[guide](https://ellmer.tidyverse.org/reference/chat_openai.html?q=OPENAI_API_KEY#arg-api-key)
how set it up in your RStudio.

## Installation

You can install the development version of `errormindR` from
[GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("thesherzad/errormindR")
```

## Example

This is a basic example which shows you can call it:

``` r
library(errormindR)
log("123") |> minerr()

# after that's run
minerr_log()
```
