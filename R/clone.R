#' Git clone
#'
#' Clone Github repo
#'
#' @param repo Github repo username/repo
#' @return Clones repo froms current directory
#' @export
git_clone <- function(repo) {
	system(paste0("git clone git@github.com:", repo, ".git"))
}
