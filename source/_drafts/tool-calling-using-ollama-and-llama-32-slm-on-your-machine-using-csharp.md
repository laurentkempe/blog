---
title: 'Tool calling using Ollama and Llama 3.2 SLM on your machine using C#'
permalink: /2024/09/27/tool-calling-using-ollama-and-llama-32-slm-on-your-machine-using-csharp/
date: 9/27/2024 10:51:12 PM
disqusIdentifier: 20240927105112
coverSize: partial
tags: [AI, C#, LLM, Ollama, SLM]
coverCaption: 'LO Ferré, Petite Anse, Martinique, France'
coverImage: 'https://c7.staticflickr.com/9/8689/16775792438_e45283970c_h.jpg'
thumbnailImage: 'https://c7.staticflickr.com/9/8689/16775792438_8366ee5732_q.jpg'
---

Introduction about "Tool calling using Ollama and Llama 3.2 SLM on your machine using C#"

<!-- more -->
# Introduction

Tool calling in AI, often referred to as function calling, is a feature that allows AI models, particularly Large Language Models (LLMs), to perform tasks beyond simple text generation by invoking predefined functions. This capability significantly enhances the interaction between humans and AI applications, allowing for more complex and structured outputs.

In essence, tool calling enables an AI model to use external tools, such as APIs and functions, to respond to prompts with more than just text. For example, an AI could be prompted to retrieve the weather forecast for a specific location. Instead of generating a text-based guess, the model can invoke a function that interacts with a weather API to provide accurate, real-time data.

The process involves two main components: the function name and a structured set of arguments, usually defined using JSONSchema. These arguments are essential for executing the specified function. The beauty of tool calling lies in its simplicity and efficiency. It offloads the responsibility of parsing structured output to the model providers, such as OpenAI, allowing for more accurate and reliable responses.

Tool calling is particularly useful for creating modular and scalable AI systems. It provides a way to structure outputs consistently, simplifies the interaction by embedding the concept directly into the model, and offers a secure method to prevent users from manipulating the model's output in unintended ways.

The introduction of tool calling has opened up new possibilities for AI applications, making them more versatile and powerful tools in various industries.



Continue with text displayed on the blog page
![alt image](https://live.staticflickr.com/65535/49566323082_e1817988c2_c.jpg)
{% alert info %}
{% endalert %}
{% codeblock GreeterService.cs lang:csharp %}
{% endcodeblock %}

```csharp	
var ollama = new OllamaApiClient(new Uri("http://localhost:11434"));

var request = new ChatRequestBuilder()
    .SetModel("llama3.2:3b")
    .AddMessage("What is the weather like in Illzach, France?", "user")
    .AddTool(
        type: "function", 
        functionName: "get_current_weather", 
        functionDescription: "Get the current weather for a city", 
        parameterType: "object", 
        properties: new Dictionary<string, Properties> 
        {
            { "city", new Properties { Type = "string", Description = "The city to get the weather for" } }
        },
        required: ["city"])
    .Build();

await foreach (var responseStream in ollama.Chat(request)) Console.Write(responseStream?.Message.Content ?? "");
```

Running this code will output the following:

```powershell
{"name":"get_current_weather","parameters": {"city": "Illzach, France"}}
```

# Conclusion
TODO
<p></p>
{% githubCard user:laurentkempe repo:dotfiles align:left %}

# References

- [Ollama Tool support](https://www.ollama.com/blog/tool-support)
- [Llama 3.2 SLM](https://ollama.com)
