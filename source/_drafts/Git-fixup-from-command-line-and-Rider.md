---
title: Git fixup from command line and Rider
permalink: '2021/01/16/Git fixup from command line and Rider/'
tags:
  - Git
  - Rider
date: 2021-01-16 11:37:20
disqusIdentifier: 20210116113720
---
While working with version control system like Git you often end up wanting to re-organize your commits while working on some new feature. You mostly do that to have a clean history or ease the review process. One great way of achieving this is Git fixup. We will see how you can achieve this using the command line, which I am a big fan of, but also how efficient it can be to use JetBrains Rider to achieve the same goal.
<!-- more -->
# Command line

# Rider

Before starting with Rider you have to configure Version Control -> Commit and unitck the "Clear initial commit message" option. If you are using IntelliJ IDEA, this setting is already un-ticked.

Rider and IDEA have slightly different defaults under Version Control->Commit. Specifically, Rider enables the "Clear initial commit message" option, while IDEA does not. Fixup should work as expected once you disable this option.
Currently "Clear initial commit message" affects fixup, but we have an open issue about this (regrettably, we do not have an ETA yet)
