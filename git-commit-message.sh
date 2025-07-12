# -----------------------------------------------------------------------------
# AI-powered Git Commit Function
# Copy paste this gist into your ~/.bashrc or ~/.zshrc to gain the `gcm` command. It:
# 1) gets the current staged changed diff
# 2) sends them to an LLM to write the git commit message
# 3) allows you to easily accept, edit, regenerate, cancel
# But - just read and edit the code however you like
# the `llm` CLI util is awesome, can get it here: https://llm.datasette.io/en/stable/

gcm() {
    # Function to generate commit message
    generate_commit_message() {
        git diff --cached | claude -p --model sonnet "
Below is a diff of all staged changes, coming from the command:
\`\`\`
git diff --cached
\`\`\`

Please generate a concise, one-line conventional commit message for these changes. under 70 characters.

If branch name looks like ticket id (e.g. FEAT-123), include it at the beginning of the commit message (e.g. [FEAT-123] feat: add new feature).
If branch name is not a ticket id, don't include it in the commit message.
If branch name looks like a conventional commit prefix (e.g. feat: , fix: , refactor: , chore: , docs: , test: , perf: , ci: , style: ), include it in the commit message.

Current branch name is: $(git branch --show-current)
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
    echo "Generating AI-powered commit message..."
    commit_message=$(generate_commit_message)
    commit_message=$(echo "$commit_message" | grep -v '^\s*```' | head -n 1 | tr -d '\n')

    while true; do
        echo -e "\nProposed commit message:"
        echo "$commit_message"

        read_input "Do you want to (a)ccept, (e)dit, (r)egenerate, or (c)ancel? "
        choice=$REPLY

        case "$choice" in
            a|A )
                if git commit -m "$commit_message"; then
                    echo "Changes committed successfully!"
                    return 0
                else
                    echo "Commit failed. Please check your changes and try again."
                    return 1
                fi
                ;;
            e|E )
                read_input "Enter your commit message: "
                commit_message=$REPLY
                if [ -n "$commit_message" ] && git commit -m "$commit_message"; then
                    echo "Changes committed successfully with your message!"
                    return 0
                else
                    echo "Commit failed. Please check your message and try again."
                    return 1
                fi
                ;;
            r|R )
                echo "Regenerating commit message..."
                commit_message=$(generate_commit_message)
                ;;
            c|C )
                echo "Commit cancelled."
                return 1
                ;;
            * )
                echo "Invalid choice. Please try again."
                ;;
        esac
    done
}
