# Get dotfiles under control

This is my personal dotfiles repo. I created it a long time ago. I created it first from a fork of https://github.com/mathiasbynens/dotfiles.git, and later I created the current branch `dotbot` when I added the [Dotbot](https://github.com/anishathalye/dotbot) dotfiles management tool. Working out of this out-of-date long-running not-main branch is gross, I need to tighten up.

Here's what I would like to do:

- `dotbot` branch is the most current, I'd like to get all of that into `main`
- I want to use dotbot (the tool) to manage my dotfiles, things like oh-my-zsh feel too heavy
- I use a combination of homebrew and asdf to install things but I'm not sure I want this in my dotfiles
- I use zsh exclusively, if there is anything bash-specific it can go unless there is a reason to keep it
- I'd love to see a summary of what's going on in here:
  - If there are dumb things in here let's delete them
  - If there are newer or more powerful ways to do things I am doing here, I'd love to hear about them
  - If there are things in here that I'm not using that are creating bloat, let me know and let's delete them

I want this repo to be:
- clean
- easy to understand
- extensible
- helpful to me in making me more conversant and capable in the shell

Please also look at my $HOME folder and suggest anything that should be added to dotfiles. My goal is a (reasonably) portable setup that can recreate my $HOME folder with the config I have defined in this dotfiles repo.

Can you help me come up with a plan to do this? Please ask any questions you like about my usage, tool choices, or habits as we go along.
