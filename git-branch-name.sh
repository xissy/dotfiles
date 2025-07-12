gbn() {
    # Function to generate branch name
    generate_branch_name() {
        git diff --cached | claude -p --model sonnet "
Below is a diff of all staged changes, coming from the command:
\`\`\`
git diff --cached
\`\`\`

Please generate an appropriate git branch name for the current changes.

Rules:
1. Start with one of these prefixes (a conventional commit prefix):
  - feat: new feature
  - fix: bug fix
  - refactor: refactoring
  - chore: miscellaneous tasks
  - docs: documentation changes
  - test: test code changes
  - perf: performance improvements
  - ci: CI configuration changes
  - style: code style changes
2. Add '/' after prefix, use only lowercase and hyphens(-)
3. Add brief description after prefix (e.g. feat/add-login-page)
4. Total length should be under 50 characters
5. Return only the branch name, without any explanation
"
    }

    # Function to read user input compatibly with both Bash and Zsh
    read_input() {
        if [ -n "$ZSH_VERSION" ]; then
            echo -n "$1"
            read -r REPLY
        else
            read -p "$1" -r REPLY
        fi
    }

    # Main script
    echo "Generating AI-powered branch name..."
    branch_name=$(generate_branch_name)

    while true; do
        echo -e "\nProposed branch name:"
        echo "$branch_name"

        read_input "Do you want to (a)ccept, (e)dit, (r)egenerate, or (c)ancel? "
        choice=$REPLY

        case "$choice" in
            a|A )
                if git checkout -b "$branch_name"; then
                    echo "Branch created and checked out successfully!"
                    return 0
                else
                    echo "Branch creation failed. Please check the branch name and try again."
                    return 1
                fi
                ;;
            e|E )
                read_input "Enter your branch name: "
                branch_name=$REPLY
                if [ -n "$branch_name" ] && git switch -c "$branch_name"; then
                    echo "Branch created and checked out successfully with your name!"
                    return 0
                else
                    echo "Branch creation failed. Please check the name and try again."
                    return 1
                fi
                ;;
            r|R )
                echo "Regenerating branch name..."
                branch_name=$(generate_branch_name)
                ;;
            c|C )
                echo "Branch creation cancelled."
                return 1
                ;;
            * )
                echo "Invalid choice. Please try again."
                ;;
        esac
    done
} 
