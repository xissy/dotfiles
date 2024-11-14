# Function to get the name of the main (default) branch
git_main_branch() {
	# Ensure origin/HEAD is set
	git remote set-head origin --auto >/dev/null 2>&1

	# Get the main branch name
	git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@'
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

# Function to delete all local branches except main
gdeleteall() {
    # Function to print help
    print_help() {
        cat << EOF
Usage:
    gdeleteall
        Delete all local branches except main.

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
                echo "gdeleteall: [Error] Unexpected argument: $1" >&2
                return 1
                ;;
        esac
    done

    # Verify git repository
    git rev-parse --git-dir > /dev/null || return $?

    # Get current and main branches
    current_branch="$(git rev-parse --abbrev-ref HEAD)"
    main_branch="$(git_main_branch --quiet)"

    echo "Current branch: $current_branch"
    echo "Main branch: $main_branch"

    # Get all branches except main
    branches_to_delete=($(git for-each-ref --format='%(refname:short)' refs/heads/ | grep -v "^${main_branch}$"))

    if [ ${#branches_to_delete[@]} -eq 0 ]; then
        echo "No branches to delete."
        return 0
    fi

    # Show branches to be deleted
    echo "The following branches will be deleted:"
    printf '%s\n' "${branches_to_delete[@]}"

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
            for branch in "${branches_to_delete[@]}"; do
                if [[ $branch == $current_branch ]]; then
                    if ! git-is-worktree-clean -q; then
                        echo "gdeleteall: [Error] Cannot delete current branch: Working tree has changes." >&2
                        return 1
                    fi
                    git switch "$main_branch" &&
                    git branch -D "$branch"
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
