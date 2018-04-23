# rb.zsh-theme

A ZSH theme based on [agnoster](https://github.com/agnoster/agnoster-zsh-theme), optimised for people who:

- Like Solarized
- Use Git
- Love fancy powerline-like themes

This has been tweaked under Mac with Solarized dark and a good Unicode font (Fira Code Light)

# Compatibility

__This comes straight from [agnoster](https://github.com/agnoster/agnoster-zsh-theme), since my theme uses the same formatting code_

In all likelihood, you will need to install a [Powerline-patched font](https://github.com/Lokaltog/powerline-fonts) for this theme to render correctly.

To test if your terminal and font support it, check that all the necessary characters are supported by copying the following command to your terminal: `echo "\ue0b0 \u00b1 \ue0a0 \u27a6 \u2718 \u26a1 \u2699"`. The result should look like this:

![Character Example](https://gist.githubusercontent.com/agnoster/3712874/raw/characters.png)

## What does it show?

- Current git project, if any
- Working directory, without path
- Git status
  - Branch () or detached head (➦)
  - Current (shortened) branch with some tweaks / SHA1 in detached head state
  - Dirty working directory (±, color change)
- Error status (color change)

![Screenshot](screenshot.png)


## Shortened branches

I use a small, inlined `awk` script to shorten `git` branches depending on some rules:

- Check which is the likely word/concept separator (chooses between slash or dash)
- Split by separator and shorten each word to 4 letters unless it matches our
  JIRA ticket format (in this case keep full, see screenshot)

## Helpers

A helper function (which I alias to `oj`) opens the corresponding JIRA issue.
Similarly, `og` opens the github page for the project. This last one could be in
my general zsh configuration, but I decided to bind it to the theme code (since
it is when it occurred to me)

## Possible changes

I may tweak it to apply the non-shortening of ticket numbers to follow also the
Spark ticket system, and add the corresponding issue tracker helper.
