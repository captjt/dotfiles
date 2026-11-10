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

-- rex-reviewer (github.com/captjt/rex-reviewer): agent PR reviews, with its
-- reviewer_* actions. Its config is ~/.config/rex-reviewer/config.lua.
load_local(HOME .. "/git/captjt/rex-reviewer/init.lua")

-- rex-inbox (github.com/captjt/rex-inbox): its inbox_rpc action, which agents
-- on other Rex hosts use to reach the hub on this machine.
load_local(HOME .. "/git/captjt/rex-inbox/rex/init.lua")
