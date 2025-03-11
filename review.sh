#!/bin/bash

# Ensure a PR number is provided or detected
pr_number=""
if [[ -n "$1" ]]; then
    pr_number="$1"
else
    pr_number=$(gh pr view --json number -q '.number' 2>/dev/null)
fi

if [[ -z "$pr_number" ]]; then
    echo "❌ No pull request found. Provide a PR number as an argument."
    exit 1
fi

echo "🔍 Reviewing PR #$pr_number..."

repo=$(basename "$(git rev-parse --show-toplevel)")

tmpdir="/tmp/pr_${repo}_${pr_number}"
mkdir -p "$tmpdir"

# Fetch PR details
base_branch=$(gh pr view "$pr_number" --json baseRefName -q '.baseRefName')
head_branch=$(gh pr view "$pr_number" --json headRefName -q '.headRefName')
changed_files=$(gh pr view "$pr_number" --json files -q '.files.[].path')
echo "📦 Base Branch: $base_branch"
echo "🚀 Head Branch: $head_branch"
echo "📄 Changed Files: $changed_files"

if [[ -z "$changed_files" ]]; then
    echo "❌ No changed files detected in PR #$pr_number."
    exit 1
fi

# Ensure we have up-to-date branches
git fetch origin "$base_branch" "$head_branch"

# Cycle through changed files
for file in $changed_files; do

    filename=$(basename "$file")
    base_file=$(mktemp -p $tmpdir -t "$filename.base")
    head_file=$(mktemp -p $tmpdir -t "$filename.head")
    comment_file=$(mktemp -p $tmpdir -t "$filename.comment")

    # Get the BASE version (before PR changes)
    git show "origin/$base_branch:$file" > "$base_file" 2>/dev/null || echo "❌ Error retrieving base file: $file"

    # Get the HEAD version (PR branch)
    git show "origin/$head_branch:$file" > "$head_file" 2>/dev/null || echo "❌ Error retrieving head file: $file"

    # Open MacVim in diff mode with comments below
    mvim -d -f "$base_file" "$head_file" \
      -c "botright 5split $comment_file" \
      -c "i|### $file" \
    
    # Cleanup temp files
    rm -f "$base_file" "$head_file"
done

comment_files=$(ls $tmpdir | grep "comment")
comment_text=""
echo "📝 Review Comments for PR #$pr_number:"
for file in $comment_files; do
  f="$tmpdir/$file"
  if [[ -s "$f" ]]; then
    comment_text+="$(cat "$f")

    "
    fi
done

if [[ -n "$comment_text" ]]; then
  echo -e "$comment_text"
  read -p "Send Comments (Y/n)? " choice
  choice=${choice:-Y}
  case "$choice" in
      [Nn]* ) 
          echo "❌ Comments not submitted."
          ;;
      [Yy]* ) 
              gh pr review "$pr_number" --comment --body "$comment_text"
              echo "✅ Comments submitted to PR #$pr_number."
          ;;
  esac
else
    echo "⚠️ No comments found. Nothing was submitted."
fi

read -p "Approve PR (Y/n)? " choice
choice=${choice:-Y}
case "$choice" in
    [Nn]* ) 
        echo "❌ PR not approved."
        ;;
    [Yy]* ) 
            gh pr review "$pr_number" --approve
            echo "✅ PR #$pr_number approved."
        ;;
esac

rm -rf $tmpdir
