{ lib, ... }:
{
  home.activation.linkGlobalAgentSkills = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    skills_dir="$HOME/.agents/skills"

    if [ -d "$skills_dir" ]; then
      backup_existing_path() {
        path="$1"
        backup_path="$path.backup.$(date +%Y%m%d%H%M%S)"

        mv "$path" "$backup_path"
        echo "Backed up existing $path to $backup_path"
      }

      for consumer_dir in "$HOME/.codex/skills" "$HOME/.claude/skills" "$HOME/.factory/skills"; do
        consumer_parent="$(dirname "$consumer_dir")"
        [ -d "$consumer_parent" ] || continue

        mkdir -p "$consumer_dir"

        for skill_path in "$skills_dir"/*; do
          [ -d "$skill_path" ] || continue

          skill_name="$(basename "$skill_path")"
          link_path="$consumer_dir/$skill_name"

          if [ -L "$link_path" ]; then
            continue
          fi

          if [ -e "$link_path" ]; then
            backup_existing_path "$link_path"
          fi

          ln -s "$skill_path" "$link_path"
        done
      done
    fi
  '';
}
