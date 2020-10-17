---
title: Mixing multiple .NET Hosts in one application
permalink: /2020/10/13/Mixing-multiple-dotNET-Hosts-in-one-application/
coverSize: partial
tags:
  - ASP.NET Core
  - WPF
  - .NET Generic Host
coverCaption: 'Lomont, France'
coverImage: 'https://live.staticflickr.com/65535/40799340353_d89917ebf5_h.jpg'
thumbnailImage: 'https://live.staticflickr.com/65535/40799340353_eb76ac9065_q.jpg'
date: 2020-10-13 20:29:59
disqusIdentifier: 20201013202959
---
In some of my last blog posts, I looked at [.NET Core 3.0, IOC, WPF](https://laurentkempe.com/2019/04/18/WPF-and-IOC-on-NET-Core-3-0/) and [.NET Generic Host](https://laurentkempe.com/2019/09/03/WPF-and-dotnet-Generic-Host-with-dotnet-Core-3-0/). In this one, I would like to explore the possibility to have **a .NET Core 3.1 WPF application exposing an ASP.NET Web API**. I will leverage what we learned in the two previous posts about IOC and .NET Generic Host to achieve that goal.

This sounds like a silly idea 💡, so it is definitely interesting 😁!
<!-- more -->

# Why

There is no real usage planned out of it, it is a research project. Never the less, I could imagine some usages. For example, being able to automate a part of the application from the external world. Or to migrate incrementally a thick client application to a client-server application. And finally even more crazy idea, but that's for some other time.

# WPF and .NET Generic Host

We start from the code described in the post "[WPF and .NET Generic Host with .NET Core 3.0](https://laurentkempe.com/2019/09/03/WPF-and-dotnet-Generic-Host-with-dotnet-Core-3-0/)". So, when the WPF application starts, it is in the *App* class constructor that the host is built, then on the *Application_Startup* it is started asynchronously and finally in *Application_Exit* it is stopped.

This time we will a different approach

# Including ASP.NET Core Host

# Result

# Conclusion

We have seen that it is quite straight forward to integrate an ASP.NET Core host into a WPF application which uses already a .NET Generic host. Now, the next question is, could we have this two parts communicate. We might see this in another post.

# Get the code on Github 👩🏼‍💻

TODO update link
{% githubCard user:laurentkempe repo:dotfiles align:left %}
