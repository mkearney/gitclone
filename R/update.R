

github_username <- function() {
  u <- Sys.getenv("GITHUB_USERNAME")
  if (identical(u, "") && interactive()) {
    u <- tfse::readline_("What is your Github username?")
    u <- gsub("^[\\s[:punct:]]+|[\\s[:punct:]]+$", "", u)
    tfse::set_renv(GITHUB_USERNAME = u)
  }
  u
}

update_repo <- function(repo) {
  update_repo_ <- function(repo) {
    ## on exit, return to this directory
    owd <- getwd()
    on.exit(setwd(owd), add = TRUE)

    ## clone from Github if doesn't exist otherwise git pull
    if (!dir.exists(repo)) {
      ## get github username
      username <- github_username()
      cat("\n")
      tfse::print_start("{",
        repo,
        "} not found; cloning from ",
        username,
        "'s Github...")
      gitclone::git_clone(paste0(username, "/", repo))
      tfse::print_complete(username, "/", repo, " was successfully cloned!")
      setwd(repo)
    } else {
      cat("\n")
      tfse::print_start("{", repo, "} found; pulling updates...")
      setwd(repo)
      sh <-
        capture.output(sh <-
            suppressMessages(system("git pull", intern = TRUE)))
    }

    ## build package
    tfse::print_start("Building documentation...")
    capture.output(sh <- suppressWarnings(suppressMessages(devtools::document())))
    tfse::print_start("Installing package...")
    capture.output(sh <- suppressMessages(
      devtools::install(
        reload = FALSE,
        quiet = TRUE,
        upgrade = "always"
      )
    ))
    tfse::print_complete("{", repo, "} was successfully updated!")
    invisible(TRUE)
  }
  o <- lapply(repo, update_repo_)
  names(o) <- repo
  o
}
