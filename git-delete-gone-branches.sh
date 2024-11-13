# Function to get the name of the main (default) branch
git_main_branch() {
	local quiet=0

	# Parse arguments
	while [[ $# -gt 0 ]]; do
		case "$1" in
			-q|--quiet)
				quiet=1
				shift
				;;
			*)
				return 1
				;;
		esac
	done

	local result
	if [[ quiet -eq 0 ]]; then
		result="$(git rev-parse --abbrev-ref origin/HEAD --)"
	else
		result="$(git rev-parse --verify --quiet --abbrev-ref origin/HEAD --)"
	fi &&
	echo "${result#origin/}"
}

# Function to delete local branches that no longer exist on remote
ggone() {
	# Function to print help
	print_help() {
		cat << EOF
Usage:
	ggone
		Delete local branches that no longer exist on remote.

Options:
	-?, --help
		Show this help information and exit.
EOF
	}

	# Parse arguments
	while [[ $# -gt 0 ]]; do
		case "$1" in
			-\?|--help)
				print_help
				return 0
				;;
			*)
				echo "ggone: [Error] Unexpected argument: $1" >&2
				return 1
				;;
		esac
	done

	# Verify git repository
	git rev-parse --git-dir > /dev/null || return $?

	# Fetch and prune
	git fetch --all --prune || return $?

	# Get current and main branches
	current_branch="$(git rev-parse --abbrev-ref HEAD)"
	main_branch="$(git_main_branch --quiet)"

	# Get list of gone branches
	gone_branches=($(git for-each-ref --format '%(refname) %(upstream:track)' refs/heads | awk '$2 == "[gone]" {sub("refs/heads/", "", $1); print $1}'))

	if [ ${#gone_branches[@]} -eq 0 ]; then
		echo "No branches to delete."
		return 0
	fi

	# Show branches to be deleted
	echo "The following branches will be deleted:"
	printf '%s\n' "${gone_branches[@]}"

	# Function to read user input compatibly with both Bash and Zsh
	read_input() {
		if [ -n "$ZSH_VERSION" ]; then
			echo -n "$1"
			read -r REPLY
		else
			read -p "$1" -r REPLY
		fi
	}

	read_input "Do you want to proceed? (y/N) "
	choice=$REPLY

	case "$choice" in
		y|Y )
			for branch in "${gone_branches[@]}"; do
				if [[ $branch == $current_branch ]]; then
					if [[ $branch != $main_branch ]]; then
						if ! git-is-worktree-clean -q; then
							echo "ggone: [Error] Cannot delete current branch: Working tree has changes." >&2
							return 1
						fi
						git switch "$main_branch" &&
						git branch -D "$branch"
					else
						echo "ggone: [Error] Cannot delete main branch '$main_branch'." >&2
					fi
				else
					git branch -D "$branch"
				fi
			done
			echo "Branches deleted successfully!"
			;;
		* )
			echo "Operation cancelled."
			return 1
			;;
	esac
}
