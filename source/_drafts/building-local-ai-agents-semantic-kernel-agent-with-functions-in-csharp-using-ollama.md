---
title: 'Building Local AI Agents: Semantic Kernel Agent with Functions in C# using Ollama'
permalink: /2025/03/02/building-local-ai-agents-semantic-kernel-agent-with-functions-in-csharp-using-ollama/
date: 3/2/2025 10:20:26 AM
disqusIdentifier: 20250302102026
coverSize: partial
tags: [AI, C#, LLM, Ollama, SLM, Semantic Kernel]
coverCaption: 'Liebvillers, France'
coverImage: 'https://live.staticflickr.com/65535/54287470437_450c3b50c6_h.jpg'
thumbnailImage: 'https://live.staticflickr.com/65535/54287470437_fdf95c0b3c_q.jpg'
---
In my previous post, we saw how to [build the simplest Semantic Kernel local AI agent using Semantic Kernel and Ollama in C#](https://laurentkempe.com/2025/03/01/building-local-ai-agents-semantic-kernel-and-ollama-in-csharp/). In this short post, we will see how simple it is to extend the capabilities of the  Semantic Kernel local AI agent to add funtions calling.
<!-- more -->

# Introduction

Functions calling, or sometime called tools, are a powerful way to extend the capabilities of your local AI agent. They allow you to call external APIs, access databases, and perform other tasks that are not possible with the built-in functions of the Semantic Kernel. To get a better understanding of function calling, you might read [Learning AI function calling in C# with Llama 3.2 SLM and Ollama running on your machine](https://laurentkempe.com/2024/10/28/learning-ai-function-calling-in-csharp-with-llama-32-slm-and-ollama-running-on-your-machine/), in which I describe the core concepts of function calling.

# Extending the Simplest Non-agentic Agent with Functions

I won't go with the process of creating the console application and adding the required NuGet packages. You can refer to the previous post for that.

This time we are using the llama3.2 model with Ollama, so that the SLM understand function calling.

Let’s enhance the simplest non-agentic agent using functions calling by updating the created `Program.cs` file with

```csharp
var builder = Kernel.CreateBuilder();
// 👇🏼 Using llama3.2 with Ollama
builder.AddOllamaChatCompletion("llama3.2:3b", new Uri("http://localhost:11434"));

var kernel = builder.Build();

ChatCompletionAgent agent = new() // 👈🏼 Definition of the agent
{
    Instructions = 
    """
    Answer questions about different locations.
    For France, use the time format: HH:MM.
    HH goes from 00 to 23 hours, MM goes from 00 to 59 minutes.
    """,
    Name = "Location Agent",
    Kernel = kernel,
    // 👇🏼 Allows the model to decide whether to call the function
    Arguments = new KernelArguments(new PromptExecutionSettings 
        { FunctionChoiceBehavior = FunctionChoiceBehavior.Auto() })
};

// 👇🏼 Define a plugin time tool
var plugin =
    KernelPluginFactory.CreateFromFunctions(
        "Time",
        "Get the current time for a city",
        [KernelFunctionFactory.CreateFromMethod(GetCurrentTime)]);
agent.Kernel.Plugins.Add(plugin);

ChatHistory chat =
[
    new ChatMessageContent(AuthorRole.User, "What time is it in Illzach, France?")
];

await foreach (var response in agent.InvokeAsync(chat))
{
    chat.Add(response);
    Console.WriteLine(response.Content);
}

// 👇🏼 Define a time tool
[Description("Get the current time for a city")]
string GetCurrentTime(string city) =>
    $"It is {DateTime.Now.Hour}:{DateTime.Now.Minute} in {city}.";
```

It is just a matter of adding a plugin to the Kernel and to configure the agent allowing the model to decide whether to call the function.

Again, very impressively simple. Note that they are multiple ways to define a plugin, and I chose the simplest one for this example. 


# Running the Agent

To see your agent in action, execute this command in your terminal:

```powershell
dotnet run
```
You should see something like the following output:

```powershell
In Illzach, France, the current time is 11:00.
```

# Conclusion
We saw how easy it is to add function calling to your local AI agent in C# using Semantic Kernel and running locally with Ollama. 

In the next post, we will continue to explore the capabilities of Semantic Kernel agents running locally.

# References

* [Introduction to Semantic Kernel](https://learn.microsoft.com/en-us/semantic-kernel/overview/)
* [Semantic Kernel Agent Framework](https://learn.microsoft.com/en-us/semantic-kernel/frameworks/agent/?pivots=programming-language-csharp)
* [Semantic Kernel GitHub repository](https://github.com/microsoft/semantic-kernel)


Get the source code on GitHub [laurentkempe/aiPlayground/SKOllamaAgentWithFunction](https://github.com/laurentkempe/aiPlayground/tree/main/SKOllamaAgentWithFunction)
<p></p>
{% githubCard user:laurentkempe repo:aiPlayground align:left %}
