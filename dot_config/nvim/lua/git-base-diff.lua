local M = {}

-- 現在のブランチ名を取得
local function get_current_branch()
  local handle = io.popen("git branch --show-current 2>/dev/null")
  if not handle then
    return nil
  end
  local branch = handle:read("*a"):gsub("%s+", "")
  handle:close()
  return branch ~= "" and branch or nil
end

-- ブランチが存在するかチェック
local function branch_exists(branch)
  if not branch or branch == "" then
    return false
  end
  local handle = io.popen(string.format("git rev-parse --verify %s 2>/dev/null", branch))
  if not handle then
    return false
  end
  local result = handle:read("*a")
  handle:close()
  return result ~= ""
end

-- git show-branchを使ってbaseブランチを自動検出
local function detect_base_from_show_branch()
  local cmd = [[git show-branch | grep '*' | grep -v "$(git rev-parse --abbrev-ref HEAD)" | head -1 | awk -F'[]~^[]' '{print $2}']]
  local handle = io.popen(cmd .. " 2>/dev/null")
  if not handle then
    return nil
  end
  local base = handle:read("*a"):gsub("%s+", "")
  handle:close()
  return base ~= "" and base or nil
end

-- デフォルトのbaseブランチを探す
local function find_default_base()
  local candidates = { "main", "master", "develop", "dev" }
  for _, branch in ipairs(candidates) do
    if branch_exists(branch) then
      return branch
    end
  end
  return nil
end

-- baseブランチを取得（優先順位: show-branch > デフォルト）
function M.get_base_branch()
  local current = get_current_branch()
  if not current then
    vim.notify("Not in a git repository or detached HEAD", vim.log.levels.ERROR)
    return nil
  end

  -- 1. git show-branchで自動検出
  local base = detect_base_from_show_branch()
  if base and branch_exists(base) then
    return base, "auto-detected"
  end

  -- 2. デフォルトブランチを探す
  base = find_default_base()
  if base then
    return base, "default"
  end

  vim.notify("Could not determine base branch", vim.log.levels.WARN)
  return nil, nil
end

-- baseブランチとの差分を開く
function M.open_base_diff()
  local base, method = M.get_base_branch()
  if not base then
    return
  end

  local current = get_current_branch()
  local method_text = method and string.format(" (%s)", method) or ""
  vim.notify(string.format("Opening diff: %s...%s%s", base, current or "HEAD", method_text), vim.log.levels.INFO)
  
  -- DiffviewOpenコマンドでbaseブランチとの差分を表示（未コミット変更も含む）
  vim.cmd(string.format("DiffviewOpen %s", base))
end

-- baseブランチを表示
function M.show_base_branch()
  local current = get_current_branch()
  if not current then
    vim.notify("Not in a git repository or detached HEAD", vim.log.levels.ERROR)
    return
  end

  local base, method = M.get_base_branch()
  if base then
    local method_text = method and string.format(" (%s)", method) or ""
    vim.notify(string.format("Current: %s, Base: %s%s", current, base, method_text), vim.log.levels.INFO)
  else
    vim.notify(string.format("Current: %s, Base: (not found)", current), vim.log.levels.WARN)
  end
end

return M
