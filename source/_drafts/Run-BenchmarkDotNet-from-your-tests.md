---
title: Run BenchmarkDotNet from your test assembly
permalink: '2020/11/07Run BenchmarkDotNet from your tests/'
coverSize: partial
tags: .NET Core, .NET
coverCaption: 'LO Ferré, Petite Anse, Martinique, France'
coverImage: 'https://c7.staticflickr.com/9/8689/16775792438_e45283970c_h.jpg'
thumbnailImage: 'https://c7.staticflickr.com/9/8689/16775792438_8366ee5732_q.jpg'
date: 2020-11-07 11:25:53
disqusIdentifier: 20201107112553
---
I am working lately on some performance optimization and when you do so you need to measure things. For that kind of goals, [BenchmarkDotNet](https://benchmarkdotnet.org/) is fantastic.
So, one side I had BenchmarkDotNet and on the other my test assembly already containing some great infrastructure to build complex arrange which would put my system in the state I want to measure performance against.
How could I match those two goals?
<!-- more -->

The issue is that the test assemblies are not executables and 

I leveraged the possibility to have 

# TODO

  <PropertyGroup>
    ...
    <StartupObject>MyApplication.Core.Program</StartupObject>
  </PropertyGroup>

https://docs.microsoft.com/en-us/dotnet/csharp/language-reference/compiler-options/main-compiler-option
