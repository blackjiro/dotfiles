#!/bin/bash

if [ -z "$CLAUDE_TOOL_RESULT" ]; then
  exit 0
fi

FILE_PATH=$(echo "$CLAUDE_TOOL_RESULT" | grep -oE '"file_path":\s*"[^"]+' | sed 's/"file_path":\s*"//')

if [ -z "$FILE_PATH" ] || [ ! -f "$FILE_PATH" ]; then
  exit 0
fi

EXT="${FILE_PATH##*.}"
FILENAME=$(basename "$FILE_PATH")
DIR=$(dirname "$FILE_PATH")

format_file() {
  case "$EXT" in
  js | jsx | ts | tsx | json | md | mdx | css | scss | sass | less | html | vue | yaml | yml)
    if [ -f "$DIR/package.json" ]; then
      if [ -f "$DIR/.prettierrc" ] || [ -f "$DIR/.prettierrc.json" ] || [ -f "$DIR/.prettierrc.js" ] || [ -f "$DIR/.prettierrc.yaml" ] || [ -f "$DIR/.prettierrc.yml" ] || [ -f "$DIR/prettier.config.js" ] || grep -q '"prettier"' "$DIR/package.json" 2>/dev/null; then
        cd "$DIR" && npx prettier --write "$FILE_PATH" 2>/dev/null
      fi

      if [[ "$EXT" =~ ^(js|jsx|ts|tsx)$ ]]; then
        if [ -f "$DIR/.eslintrc" ] || [ -f "$DIR/.eslintrc.json" ] || [ -f "$DIR/.eslintrc.js" ] || [ -f "$DIR/.eslintrc.yaml" ] || [ -f "$DIR/.eslintrc.yml" ] || grep -q '"eslint"' "$DIR/package.json" 2>/dev/null; then
          cd "$DIR" && npx eslint --fix "$FILE_PATH" 2>/dev/null
        fi
      fi
    fi
    ;;

  py)
    if command -v black &>/dev/null; then
      black "$FILE_PATH" 2>/dev/null
    elif command -v ruff &>/dev/null; then
      ruff format "$FILE_PATH" 2>/dev/null
    elif command -v autopep8 &>/dev/null; then
      autopep8 --in-place "$FILE_PATH" 2>/dev/null
    fi

    if command -v ruff &>/dev/null && [ -f "$DIR/ruff.toml" ] || [ -f "$DIR/pyproject.toml" ] || [ -f "$DIR/.ruff.toml" ]; then
      ruff check --fix "$FILE_PATH" 2>/dev/null
    fi
    ;;

  go)
    if command -v gofmt &>/dev/null; then
      gofmt -w "$FILE_PATH" 2>/dev/null
    fi

    if command -v goimports &>/dev/null; then
      goimports -w "$FILE_PATH" 2>/dev/null
    fi
    ;;

  rs)
    if command -v rustfmt &>/dev/null; then
      rustfmt "$FILE_PATH" 2>/dev/null
    fi
    ;;

  rb)
    if command -v rubocop &>/dev/null && [ -f "$DIR/.rubocop.yml" ]; then
      rubocop -a "$FILE_PATH" 2>/dev/null
    fi
    ;;

  lua)
    if command -v stylua &>/dev/null && [ -f "$DIR/stylua.toml" ] || [ -f "$DIR/.stylua.toml" ]; then
      stylua "$FILE_PATH" 2>/dev/null
    fi
    ;;

  sh | bash)
    if command -v shfmt &>/dev/null; then
      shfmt -w "$FILE_PATH" 2>/dev/null
    fi
    ;;

  toml)
    if command -v taplo &>/dev/null; then
      taplo fmt "$FILE_PATH" 2>/dev/null
    fi
    ;;
  esac
}

format_file

exit 0

