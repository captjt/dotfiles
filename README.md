# captjt's dotfiles

### To Install

#### Note: Ensure git is installed

```shell
git clone https://github.com/captjt/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh
```

### Shared agent skills

Global skills live in `agents/skills` and are installed through `~/.agents`. The installer also fans them out to supported coding-agent skill directories when those agents are present.

Refresh only the shared agent-skill links with:

```shell
just agent-skills
```
