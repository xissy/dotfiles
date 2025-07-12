# -----------------------------------------------------------------------------
# AI-powered Git PR Description Function
# Copy paste this gist into your ~/.bashrc or ~/.zshrc to gain the `gpr` command. It:
# 1) gets the diff between current branch and main branch
# 2) sends them to an LLM to write the PR title and description
# 3) allows you to easily accept, edit, regenerate, cancel

gpr() {
    # Function to generate PR title and description
    generate_pr_content() {
        git diff main...HEAD | claude -p --model sonnet "
Below is a diff between the current branch and main branch, coming from the command:
\`\`\`
git diff main...HEAD
\`\`\`

Current branch name is: $(git branch --show-current)

Please generate a PR title and description for these changes.

PR Title Requirements:
- Use conventional commit format (feat:, fix:, refactor:, chore:, docs:, test:, perf:, ci:, style:)
- If branch name looks like ticket id (e.g. FEAT-123), include it at the beginning (e.g. [FEAT-123] feat: add new feature)
- Keep under 70 characters
- One line only

PR Description Requirements:
- Write in Korean (한글)
- Use markdown format
- Include sections like: ## 변경사항, ## 테스트 방법, ## 체크리스트
- Be concise but informative
- Focus on what changed and why

Format your response exactly like this:
TITLE: [your PR title here]

DESCRIPTION:
[your PR description in markdown format here]
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

    # Check if we're on main branch
    current_branch=$(git branch --show-current)
    if [ "$current_branch" = "main" ] || [ "$current_branch" = "master" ]; then
        echo "Error: You're currently on the main/master branch. Please switch to a feature branch first."
        return 1
    fi

    # Check if there are differences with main
    if ! git diff --quiet main...HEAD; then
        echo "Generating AI-powered PR title and description..."
        pr_content=$(generate_pr_content)
        
        # Extract title and description
        pr_title=$(echo "$pr_content" | grep "^TITLE:" | sed 's/^TITLE: //')
        pr_description=$(echo "$pr_content" | sed -n '/^DESCRIPTION:/,$p' | sed '1d')
    else
        echo "No differences found between current branch and main."
        return 1
    fi

    while true; do
        echo -e "\n=== Proposed PR Title ==="
        echo "$pr_title"
        echo -e "\n=== Proposed PR Description ==="
        echo "$pr_description"

        read_input $'\nDo you want to (a)ccept, (e)dit, (r)egenerate, or (c)ancel? '
        choice=$REPLY

        case "$choice" in
            a|A )
                echo -e "\n=== Final PR Title ==="
                echo "$pr_title"
                echo -e "\n=== Final PR Description ==="
                echo "$pr_description"
                echo -e "\n✅ PR content ready! Copy the title and description above for your PR."
                return 0
                ;;
            e|E )
                echo -e "\n--- Edit PR Title ---"
                read_input "Enter PR title: "
                pr_title=$REPLY
                echo -e "\n--- Edit PR Description ---"
                echo "Enter PR description (press Ctrl+D when done):"
                pr_description=$(cat)
                ;;
            r|R )
                echo "Regenerating PR content..."
                pr_content=$(generate_pr_content)
                pr_title=$(echo "$pr_content" | grep "^TITLE:" | sed 's/^TITLE: //')
                pr_description=$(echo "$pr_content" | sed -n '/^DESCRIPTION:/,$p' | sed '1d')
                ;;
            c|C )
                echo "PR content generation cancelled."
                return 1
                ;;
            * )
                echo "Invalid choice. Please try again."
                ;;
        esac
    done
}