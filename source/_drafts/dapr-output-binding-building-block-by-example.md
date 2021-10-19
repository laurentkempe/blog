---
title: 'Dapr binding building block by simple example'
permalink: /2021/04/07/dapr-binding-building-block-by-simple-example/
date: 4/7/2021 8:22:22 PM
disqusIdentifier: 20210407082222
coverSize: partial
tags: [.NET, Dapr]
coverCaption: 'LO Ferré, Petite Anse, Martinique, France'
coverImage: 'https://c7.staticflickr.com/9/8689/16775792438_e45283970c_h.jpg'
thumbnailImage: 'https://c7.staticflickr.com/9/8689/16775792438_8366ee5732_q.jpg'
---
Till now, we have seen two [Dapr building blocks](https://laurentkempe.com/tags/Dapr/) which are the [service to service invocation building block](https://docs.dapr.io/developing-applications/building-blocks/service-invocation/service-invocation-overview/) and the [secrets building block](https://docs.dapr.io/developing-applications/building-blocks/secrets/secrets-overview/). The secrets building block serves to protect things like a database connection string, an API key... so that they're never disclosed outside of the application. The service to service invocation building block serves to make calls between services in your distributed application easy. In this post, we will introduce a third one which is the [bindings building block](https://docs.dapr.io/developing-applications/building-blocks/bindings/bindings-overview/). The bindings building block enable your distributed application to handle events from or invoke events in an external system.
<!-- more -->
# Introduction

Todays applications often needs to be called from other external applications or call external services.

{% alert info %}
A binding provides a bi-directional connection to an external cloud/on-premise service or system. Dapr allows you to invoke the external service through the Dapr binding API, and it allows your application to be triggered by events sent by the connected service.
{% endalert %}

What is the difference from just being called or calling yourself the external service? Like for previous building blocks the benefits are mostly similar
<p></p>

* Focus on your business logic and avoid implementation details of how to interact with an external system keeping your code free from other SDKs or third parties libraries
* Being able to swap between Dapr bindings for different environments without any code change
* Having not to care about the handling of retries and failure recoveries

# Sample application

We will implement a very simple application that will poll GitHub on a configured interval to get some data. To achieve that we will use two bindings:

1. [Cron binding](https://docs.dapr.io/reference/components-reference/supported-bindings/cron/)
1. [HTTP binding](https://docs.dapr.io/reference/components-reference/supported-bindings/http/)


![alt image](https://live.staticflickr.com/65535/49566323082_e1817988c2_c.jpg)
{% alert info %}
{% endalert %}
{% codeblock GreeterService.cs lang:csharp %}
{% endcodeblock %}
# Conclusion
TODO
<p></p>
{% githubCard user:laurentkempe repo:dotfiles align:left %}
