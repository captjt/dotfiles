-- Rex config, linked to ~/.config/rex from ~/.dotfiles/rex.

local HOME = os.getenv("HOME")

-- Actions that stay out of the repo load when they're present. A file that
-- fails to load is logged, and the rest of the config still loads.
local function load_local(path)
  local f = io.open(path, "r")
  if not f then
    return
  end
  f:close()
  local ok, err = pcall(dofile, path)
  if not ok then
    rex.log(path .. ": " .. tostring(err))
  end
end

-- pr-review: the PR review orchestrator's actions, such as pr_review_status.
load_local(HOME .. "/.config/rex/pr-review/actions.lua")
