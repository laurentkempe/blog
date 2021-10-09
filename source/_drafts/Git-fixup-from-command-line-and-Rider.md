---
title: Git fixup from command line and Rider
permalink: '2021/01/16/Git fixup from command line and Rider/'
tags: [Git, Rider]
date: 2021-01-16 11:37:20
disqusIdentifier: 20210116113720
---
While working with version control system like Git you often end up wanting to re-organize your commits while working on some new feature. You mostly do that to have a clean history or ease the review process. One great way of achieving this is Git fixup. We will see how you can achieve this using the command line, which [I am a big fan of](/2020/02/28/Automate-developer-work-using-Git-Aliases/), but also how efficient it can be to use [JetBrains Rider](https://jetbrains.com/rider) to achieve the same goal.
<!-- more -->

# Git fixup

First of all, what is Git fixup? From Git documentation you can read the following

> like "squash", but discard this commit's log message

So, it means that you start with two commits, or more, and end up with one commit and the commit that you fixup keeps its commit message and get all changes rom the other ones.

There are two ways to use Git fixup, one way is manual and the other is automatic and both are done during a rebase.

# From command line

The manual way will be done using the editor defined in your .gitconfig file while doing an [interactive rebase](https://git-scm.com/docs/git-rebase/2.1.4#Documentation/git-rebase.txt---interactive).

Here is my configuration using Notepad++
{% codeblock .gitconfig lang:shell  %}
	editor = 'C:/Program Files/Notepad++/notepad++.exe' -multiInst -notabbar -nosession -noPlugin
{% endcodeblock %}

## Git fixup manual

Imagine you want to rework your last four commits by running 

> git rebase -i HEAD~4

Notepad++ would open with something similar to

{% codeblock Git interactive rebase lang:shell  %}
pick 7f85382 Refactor way to get drafts
pick 705aeaf Add edit command
pick e738d19 Add second draft for the edit command
pick f83e98e Update publish command to ask user

# Rebase 5b088c2..f83e98e onto 5b088c2 (4 commands)
#
# Commands:
# p, pick <commit> = use commit
# r, reword <commit> = use commit, but edit the commit message
# e, edit <commit> = use commit, but stop for amending
# s, squash <commit> = use commit, but meld into previous commit
# f, fixup <commit> = like "squash", but discard this commit's log message
# x, exec <command> = run command (the rest of the line) using shell
# b, break = stop here (continue rebase later with 'git rebase --continue')
# d, drop <commit> = remove commit
# l, label <label> = label current HEAD with a name
# t, reset <label> = reset HEAD to a label
# m, merge [-C <commit> | -c <commit>] <label> [# <oneline>]
# .       create a merge commit using the original merge commit's
# .       message (or the oneline, if no original merge commit was
# .       specified). Use -c <commit> to reword the commit message.
#
# These lines can be re-ordered; they are executed from top to bottom.
#
# If you remove a line here THAT COMMIT WILL BE LOST.
#
# However, if you remove everything, the rebase will be aborted.
{% endcodeblock %}

We see that Git is helping us with all the comments which are displayed in Notepad++. The one which interesting is *# f, fixup*

## Git fixup automatic

# Using Rider

Before starting with Rider you have to configure Version Control -> Commit and un-tick the "Clear initial commit message" option. If you are using IntelliJ IDEA, this setting is already un-ticked.

Rider and IDEA have slightly different defaults under Version Control->Commit. Specifically, Rider enables the "Clear initial commit message" option, while IDEA does not. Fixup should work as expected once you disable this option.
Currently "Clear initial commit message" affects fixup, but we have an open issue about this (regrettably, we do not have an ETA yet)
