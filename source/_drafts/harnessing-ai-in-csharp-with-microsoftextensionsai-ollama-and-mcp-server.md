---
title: 'Harnessing AI in C# with Microsoft.Extensions.AI, Ollama, and MCP Server'
permalink: /2025/03/15/harnessing-ai-in-csharp-with-microsoftextensionsai-ollama-and-mcp-server/
date: 3/15/2025 12:09:22 PM
disqusIdentifier: 20250315120922
coverSize: partial
tags: [AI, C#, MCP, SLM, Ollama]
coverCaption: 'Les Vosges, France'
coverImage: 'https://live.staticflickr.com/5210/5297920398_199c438d4c_h.jpg'
thumbnailImage: 'https://live.staticflickr.com/5210/5297920398_431f7d7b27_q.jpg'
---
In the previous post "[Leveraging Microsoft.Extensions.AI for Tool Calling in C#](https://laurentkempe.com/2025/01/27/leveraging-microsoftextensionsai-for-tool-calling-in-csharp/)" we explored how to create our own tools which could be called to enhance the capabilities of Large Language Models (LLM). We saw how by integrating these technologies, developers can enhance their applications with advanced AI capabilities, enabling more complex interactions.

In this post, we will go further and see how to use **Model Context Protocol (MCP)** servers to exploit Tools and AI models in C# applications. We continue to use Ollama to use local AI models.
<!-- more -->

# Introduction

The future of AI lies not just in powerful models, but in their ability to seamlessly interact with the data that drives our world. **Model Context Protocol (MCP)**, a groundbreaking open standard designed to bridge the gap between AI systems and the diverse data sources they rely on. Launched by Anthropic, MCP simplifies the challenge of integrating AI with content repositories, business tools, and development environments. By replacing fragmented, custom integrations with a universal protocol, MCP empowers developers to create secure, scalable, and context-aware AI applications.

# Requirements

* **Llama 3.2 SLM**, a model supporting function calling
* **Ollama** to run the SLM and deal with the integration
* A .NET CLI application using **Microsoft.Extensions.AI** and **McpDotNet.Extensions.AI**

# Create a .NET Console Application

We create a simple .NET CLI application that interacts with the AI model using `Microsoft.Extensions.AI`. This library provides a unified set of AI building blocks for .NET applications, making it easy to integrate AI capabilities into your projects. We extend those capabilities by using `McpDotNet.Extensions.AI` to provide some tools via a **Model Context Protocol (MCP) server**.

```powershell
dotnet new console -n OllamaMCPServerMicrosoftExtensions
cd OllamaMCPServerMicrosoftExtensions
dotnet add package Microsoft.Extensions.AI
dotnet add package McpDotNet.Extensions.AI
```

# Implementation using Microsoft.Extensions.AI & McpDotNet.Extensions.AI

We create a simple console application leveraging `Microsoft.Extensions.AI` to interact with an llama3.2 AI model running locally using Ollama. Then we extend the capabilities of the chat client using `McpDotNet.Extensions.AI` to provide the tools which are hosted outside of our application by a MCP server.

To continue with our previous post examples we will use a **Time MCP Server** which is a simple Docker container. The container is started and stopped when we run the application.

```csharp
Console.WriteLine("Hello, Microsoft.Extensions.AI with Ollama & MCP Server !");
var message = "What is the current (CET) time in Illzach, France?";
Console.WriteLine(message);

// 👇🏼 Configure the Model Context Protocol server to use
var config = new McpServerConfig
{
    Id = "time",
    Name = "Time MCP Server",
    TransportType = TransportTypes.StdIo,
    TransportOptions = new Dictionary<string, string>
    {
        // 👇🏼 The command executed to start the MCP server
        ["command"] = "docker",
        ["arguments"] = "run -i --rm mcp/time"
    }
};

// 👇🏼 Get an MCP session scope used to get the MCP tools
await using var sessionScope = await McpSessionScope.CreateAsync(config);

using var factory =
    LoggerFactory.Create(builder => builder.AddConsole().SetMinimumLevel(LogLevel.Trace));

// 👇🏼 Use Ollama as the chat client
var ollamaChatClient =
    new OllamaChatClient(new Uri("http://localhost:11434/"), "llama3.2:3b");
var client = new ChatClientBuilder(ollamaChatClient)
    // 👇🏼 Add logging to the chat client, wrapping the function invocation client 
    .UseLogging(factory)
    // 👇🏼 Add function invocation to the chat client, wrapping the Ollama client
    .UseFunctionInvocation()
    .Build();

IList<ChatMessage> messages =
[
    new(ChatRole.System, """
                         You are a helpful assistant delivering time in one sentence
                         in a short format, like 'It is 10:08 in Paris, France.
                         """),
    new(ChatRole.User, message)
];

// 👇🏼 Pass the MCP tools to the chat client
var response =
    await client.GetResponseAsync(
        messages,
        new ChatOptions { Tools = sessionScope.Tools });

Console.WriteLine(response);
```

# Running the Application

To run the application, we simply `dotnet run` it. The application will start the **Time MCP Server** Docker container, interact with the AI model, and return the current time in Illzach, France.

```powershell
> dotnet run
Hello, Microsoft.Extensions.AI with Ollama & MCP Server !
What is the current (CET) time in Illzach, France?
trce: Microsoft.Extensions.AI.LoggingChatClient[805843669]
      GetResponseAsync invoked: [
        {
          "role": "system",
          "contents": [
            {
              "$type": "text",
              "text": "You are a helpful assistant delivering time in one sentence\r\nin a short format, like 'It is 10:08 in Paris, France."
            }
          ]
        },
        {
          "role": "user",
          "contents": [
            {
              "$type": "text",
              "text": "What is the current (CET) time in Illzach, France?"
            }
          ]
        }
      ]. Options: {}. Metadata: {
        "providerName": "ollama",
        "providerUri": "http://localhost:11434/",
        "modelId": "llama3.2:3b"
      }.
trce: Microsoft.Extensions.AI.LoggingChatClient[384896670]
      GetResponseAsync completed: {
        "messages": [
          {
            "role": "assistant",
            "contents": [
              {
                "$type": "functionCall",
                "callId": "86D17B64",
                "name": "get_current_time",
                "arguments": {
                  "timezone": "Europe/Paris"
                }
              }
            ]
          },
          {
            "role": "tool",
            "contents": [
              {
                "$type": "functionResult",
                "callId": "86D17B64",
                "result": "{\n  \"timezone\": \"Europe/Paris\",\n  \"datetime\": \"2025-03-15T12:51:31+01:00\",\n  \"is_dst\": false\n}"
              }
            ]
          },
          {
            "role": "assistant",
            "contents": [
              {
                "$type": "text",
                "text": "The current time in Illzach, France (CET) is 12:51 PM."
              }
            ]
          }
        ],
        "responseId": "2025-03-15T11:51:32.2116206Z",
        "modelId": "llama3.2:3b",
        "createdAt": "2025-03-15T11:51:32.2116206+00:00",
        "finishReason": "stop",
        "usage": {
          "inputTokenCount": 614,
          "outputTokenCount": 41,
          "totalTokenCount": 655,
          "additionalCounts": {
            "load_duration": 2706148300,
            "total_duration": 3390812700,
            "prompt_eval_duration": 238000000,
            "eval_duration": 439000000
          }
        }
      }.
The current time in Illzach, France (CET) is 12:51 PM.
```

We can see from the trace logs that the application interacts with the AI model, gets a `functionCall` answer from the assistant. `Microsoft.Extensions.AI` client calls the MCP server and gets a `functionResult` from the tool and finally the assistant gives the answer to the user based on the function call result.

We can also inspect the logs on the **Time MCP Server** Docker container to see the interaction with the application.

```powershell
2025-03-15 11:01:11
{
  "jsonrpc": "2.0",
  "id": 2,
  "result": {
    "protocolVersion": "2024-11-05",
    "capabilities": {
      "experimental": {},
      "tools": {
        "listChanged": false
      }
    },
    "serverInfo": {
      "name": "mcp-time",
      "version": "1.0.0"
    }
  }
}


2025-03-15 11:01:11 
{
  "jsonrpc": "2.0",
  "id": 3,
  "result": {
    "tools": [
      {
        "name": "get_current_time",
        "description": "Get current time in a specific timezones",
        "inputSchema": {
          "type": "object",
          "properties": {
            "timezone": {
              "type": "string",
              "description": "IANA timezone name (e.g., 'America/New_York', 'Europe/London'). Use 'UTC' as local timezone if no timezone provided by the user."
            }
          },
          "required": [
            "timezone"
          ]
        }
      },
      {
        "name": "convert_time",
        "description": "Convert time between timezones",
        "inputSchema": {
          "type": "object",
          "properties": {
            "source_timezone": {
              "type": "string",
              "description": "Source IANA timezone name (e.g., 'America/New_York', 'Europe/London'). Use 'UTC' as local timezone if no source timezone provided by the user."
            },
            "time": {
              "type": "string",
              "description": "Time to convert in 24-hour format (HH:MM)"
            },
            "target_timezone": {
              "type": "string",
              "description": "Target IANA timezone name (e.g., 'Asia/Tokyo', 'America/San_Francisco'). Use 'UTC' as local timezone if no target timezone provided by the user."
            }
          },
          "required": [
            "source_timezone",
            "time",
            "target_timezone"
          ]
        }
      }
    ]
  }
}

2025-03-15 11:01:14
{
  "jsonrpc": "2.0",
  "id": 4,
  "result": {
    "content": [
      {
        "type": "text",
        "text": "{\n  \"timezone\": \"Europe/Paris\",\n  \"datetime\": \"2025-03-15T11:01:14+01:00\",\n  \"is_dst\": false\n}"
      }
    ],
    "isError": false
  }
}
```

We can see that the connection is established, the tools are listed, and the function call is made to get the current time. Note that this log is from a previous run of the application, so the time is different.

# Conclusion

In conclusion, the Model Context Protocol (MCP) represents a transformative leap forward for AI integrations. By offering a standardized, unified method for connecting AI agents to tools and data sources, MCP simplifies development, enhances flexibility, and enables real-time, context-rich interactions. Its dynamic discovery capabilities and two-way communication set it apart from traditional APIs, paving the way for smarter, more responsive AI systems.

The future of AI looks brighter than ever, with MCP driving seamless integrations and empowering intelligent solutions across a myriad of use cases. It's an exciting time for AI enthusiasts and professionals alike, as we stand on the brink of a new era of connectivity and possibility! 🚀


# References

* [Introducing the Model Context Protocol](https://www.anthropic.com/news/model-context-protocol)
* [Model Context Protocol](https://modelcontextprotocol.io/introduction)
* [PederHP/mcpdotnet](https://github.com/PederHP/mcpdotnet)
* [Introducing Microsoft.Extensions.AI Preview – Unified AI Building Blocks for .NET](https://devblogs.microsoft.com/dotnet/introducing-microsoft-extensions-ai-preview/)
* [Time MCP Server](https://github.com/modelcontextprotocol/servers/tree/main/src/time)
* [Integrating Model Context Protocol Tools with Semantic Kernel: A Step-by-Step Guide](https://devblogs.microsoft.com/semantic-kernel/integrating-model-context-protocol-tools-with-semantic-kernel-a-step-by-step-guide/)


Get the source code on GitHub [laurentkempe/aiPlayground/OllamaMCPServerMicrosoftExtensions](https://github.com/laurentkempe/aiPlayground/tree/main/OllamaMCPServerMicrosoftExtensions).

<p></p>
{% githubCard user:laurentkempe repo:aiPlayground align:left %}
