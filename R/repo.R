#' Create Github repository
#'
#' Creates public repository on Github (from local repository)
#'
#' @return Github repo created for associated account.
#' @export
create_repo <- function() {
	path <- getwd()
	create_gh_repo(path, private = FALSE)
}

#' Create private repository on Github
#'
#' @rdname create_repo
#' @inheritParams create_repo
#' @export
create_private_repo <- function() {
	path <- getwd()
	create_gh_repo(path, private = TRUE)
}

`%||%` <- function(a, b) if (!is.null(a)) a else b



create_gh_repo <- function(path, private) {

	if (!usethis:::uses_git(path)) {

		if (!file.exists(".gitignore")) {
			cat(paste0(
				".Rhistory",
				".RData",
				".Rproj.user",
				".DS_Store",
				sep = "\n"
			), file = ".gitignore", fill = TRUE)
		}
		if (!file.exists("README.md")) {
			cat(paste0(
				"# ", basename(path), "\n"),
				file = "README.md", fill = TRUE)
		}
		git2r::init(path)
		git2r::add(path, c(".gitignore", "README.md"))
		git2r::commit(path, message = "initial commit")
	}

	## auth_token is used directly by git2r, therefore cannot be NULL
	auth_token <- usethis:::gh_token()
	usethis:::check_gh_token(auth_token)

	usethis:::done("Creating GitHub repository")

	create <- gh::gh(
		"POST /user/repos",
		name = basename(path),
		description = "description in progress",
		private = private,
		.api_url = NULL,
		.token = auth_token
	)

	usethis:::done("Adding GitHub remote")
	r <- git2r::repository(path)
	origin_url <- create$ssh_url
	git2r::remote_add(r, "origin", origin_url)

	usethis:::done("Pushing to GitHub and setting remote tracking branch")
	git2r::push(r, "origin", "refs/heads/master", credentials = NULL)
	git2r::branch_set_upstream(git2r::repository_head(r), "origin/master")

	usethis:::view_url(create$html_url)

	invisible(NULL)
}
