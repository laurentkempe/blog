---
title: 'ReSharper Command Line Tools and Git pre-commit hook'
permalink: ReSharper-Command-Line-Tools-and-Git-pre-commit-hook
disqusIdentifier: '2017-10-01 07:34:59 <!-- Remove space to have e.g. 20160405174628 -->'
coverSize: partial
tags:
  - ReSharper
  - Git
coverCaption: 'LO Ferré, Petite Anse, Martinique, France'
coverImage: 'https://c7.staticflickr.com/9/8689/16775792438_e45283970c_h.jpg'
thumbnailImage: 'https://c7.staticflickr.com/9/8689/16775792438_8366ee5732_q.jpg'
date: 2017-10-01 09:34:59
---
In my team we are using ReSharper in which we have defined C# code formatting rules which each developer is supposed to apply before pushing code to Github, or at least before asking a review of a pull request. As this is something you kind of need to remember, we just forget about it from time to time. As this is making our reviewers wasting time it is a great candidate to be automated.

Our solution is using the new ReSharper Command Line Tools; cleanupcode.exe and Git pre-commit hook.
<!-- more -->
[ReSharper Command Line Tools](https://www.jetbrains.com/help/resharper/ReSharper_Command_Line_Tools.html) has been updated in it's 2017.2 release with a new tool called codecleanup.exe which execute the same [formatting as the one defined in ReSharper](https://www.jetbrains.com/help/resharper/ReSharper_Command_Line_Tools.html) but from the command line. 

As we are using Git we have taken advantage of the hooks capabilities to have our modified or new C# files code formatted when one of our developer is adding a great new feature!

Each Git repositories has a **.git\hooks** folder which contains a set of hooks samples. The one we are interested in is the pre-commit hook. This hook is, as it names implies, executed before git commit something. We want to use that to run our code cleanup.

The goal is to use PowerShell to write our hook. So we need to start our PowerShell script from the pre-commit shell script. We also want that this PowerShell script is versioned with our code, so that it is maintained for all developers. To achieve that goal we won't place the PowerShell script in the .git\hooks folder but in the root folder of our repository. Developers would still need to have the pre-commit hook launching the PowerShell script configured.

Here is the bash script to run the code cleanup PowerShell script

{% codeblock %}
#!/bin/sh
exec powershell -NoProfile -ExecutionPolicy RemoteSigned -File '.\pre-commit.ps1'
{% endcodeblock %}

So we want that our staged files in Git are cleaned before the commit happens.

To get a list of the files which are added/copied/modified/renamed, you can use the following Git command

{% codeblock %}
git diff --cached --name-only --diff-filter=ACMR
{% endcodeblock %}

Out of the results of that command you need to build up the command which will be executed by ReSharper codecleanup.exe command.

{% codeblock %}
$files -join ';' -replace '/','\'
{% endcodeblock %}

