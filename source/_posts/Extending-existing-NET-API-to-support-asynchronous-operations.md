title: "Extending existing .NET API to support asynchronous operations"
permalink: "Extending-existing-NET-API-to-support-asynchronous-operations"
date: 1/5/2012 7:10:53 AM
updated: 11/13/2012 11:05:11 AM
disqusIdentifier: 20120105071053
coverImage: https://farm6.staticflickr.com/5057/5517072642_bc446224c7_b.jpg
coverSize: partial
thumbnailImage: https://farm6.staticflickr.com/5057/5517072642_bc446224c7_q.jpg
coverCaption: "Palmier sur la plage de la grande anse, Le Diamant, Martinique"
alias:
 - /post/Extending-existing-NET-API-to-support-asynchronous-operations.aspx/index.html
---
<!-- [![Palmier sur la plage de la grande anse du diamant](http://farm6.staticflickr.com/5057/5517072642_bc446224c7_m.jpg)](http://www.flickr.com/photos/laurentkempe/5517072642/ "Palmier sur la plage de la grande anse du diamant by Laurent Kempé, on Flickr") -->

The other day I needed a way in a project I am working on to turn a .NET API, [RestSharp](http://restsharp.org/) to name it, so that I could use it in an asynchronous way.
<!-- more -->

The goal was to have the API returning a **Task<TResult>** so that I could use it if I want with the [Async CTP](http://msdn.microsoft.com/en-us/vstudio/gg316360). I also wanted to have something running both on .NET 4.0 and on Windows Phone 7.5.** **

To achieve this goal I used 

> ### [TaskCompletionSource<TResult> Class](http://msdn.microsoft.com/en-us/library/dd449174.aspx)
> 
> **.NET Framework 4**

and defined two helper extension methods on the RestClient class of RestSharp as this:

<style type="text/css">
.csharpcode, .csharpcode pre
{
	font-size: small;
	color: black;
	font-family: consolas, "Courier New", courier, monospace;
	background-color: #ffffff;
	/*white-space: pre;*/
}
.csharpcode pre { margin: 0em; }
.csharpcode .rem { color: #008000; }
.csharpcode .kwrd { color: #0000ff; }
.csharpcode .str { color: #006080; }
.csharpcode .op { color: #0000c0; }
.csharpcode .preproc { color: #cc6633; }
.csharpcode .asp { background-color: #ffff00; }
.csharpcode .html { color: #800000; }
.csharpcode .attr { color: #ff0000; }
.csharpcode .alt 
{
	background-color: #f4f4f4;
	width: 100%;
	margin: 0em;
}
.csharpcode .lnum { color: #606060; }
.code { font-size: 12px; color: #000; font-family: Consolas, "Courier New", Courier, Monospace; background-color: #F1F1F1; line-height: normal; }
.code p		{ padding: 5px; }
.code .rem	{ color: #008000; }
.code .kwrd	{ color: #0000ff; }
.code .str	{ color: #006080; }
.code .op	{ color: #0000c0; }
.code .preproc { color: #0000ff; }
.code .asp	{ background-color: #ffff00; }
.code .html { color: #800000; }
.code .attr { color: #ff0000; }
.code .alt	{ background-color: #f4f4f4; }
.code .lnum	{ color: #606060; }
</style>

<pre style="background-color: black" class="code"><span style="color: #f92672">#region </span><span style="color: #f8f8f2">using

</span><span style="color: #f92672">using </span><span style="color: #f8f8f2">System;
</span><span style="color: #f92672">using </span><span style="color: #f8f8f2">System.Threading;
</span><span style="color: #f92672">using </span><span style="color: #f8f8f2">System.Threading.Tasks;
</span><span style="color: #f92672">using </span><span style="color: #f8f8f2">RestSharp;

</span><span style="color: #f92672">#endregion

namespace </span><span style="color: #f8f8f2">Sharper
{
    </span><span style="color: #f92672">public static class </span><span style="color: #66d9ef">RestClientExtensions
    </span><span style="color: #f8f8f2">{
        </span><span style="color: #f92672">public static </span><span style="color: #66d9ef">Task</span><span style="color: #f8f8f2">&lt;TResult&gt; ExecuteTask&lt;TResult&gt;(</span><span style="color: #f92672">this </span><span style="color: #66d9ef">RestClient </span><span style="color: #f8f8f2">client,
                                                         </span><span style="color: #66d9ef">RestRequest </span><span style="color: #f8f8f2">request) </span><span style="color: #f92672">where </span><span style="color: #f8f8f2">TResult : </span><span style="color: #f92672">new</span><span style="color: #f8f8f2">()
        {
            </span><span style="color: #f92672">var </span><span style="color: #f8f8f2">tcs = </span><span style="color: #f92672">new </span><span style="color: #66d9ef">TaskCompletionSource</span><span style="color: #f8f8f2">&lt;TResult&gt;();

            </span><span style="color: #66d9ef">WaitCallback
                </span><span style="color: #f8f8f2">asyncWork = _ =&gt;
                                {
                                    </span><span style="color: #f92672">try
                                    </span><span style="color: #f8f8f2">{
                                        client.ExecuteAsync&lt;TResult&gt;(request,
                                                                     response =&gt; tcs.SetResult(response.Data));
                                    }
                                    </span><span style="color: #f92672">catch </span><span style="color: #f8f8f2">(</span><span style="color: #66d9ef">Exception </span><span style="color: #f8f8f2">exc)
                                    {
                                        tcs.SetException(exc);
                                    }
                                };

            </span><span style="color: #f92672">return </span><span style="color: #f8f8f2">ExecuteTask(asyncWork, tcs);
        }

        </span><span style="color: #f92672">public static </span><span style="color: #66d9ef">Task</span><span style="color: #f8f8f2">&lt;TResult&gt; ExecuteTask&lt;T, TResult&gt;(</span><span style="color: #f92672">this </span><span style="color: #66d9ef">RestClient </span><span style="color: #f8f8f2">client,
                                                            </span><span style="color: #66d9ef">RestRequest </span><span style="color: #f8f8f2">request,
                                                            </span><span style="color: #66d9ef">Func</span><span style="color: #f8f8f2">&lt;T, TResult&gt; adapter) </span><span style="color: #f92672">where </span><span style="color: #f8f8f2">T : </span><span style="color: #f92672">new</span><span style="color: #f8f8f2">()
        {
            </span><span style="color: #f92672">var </span><span style="color: #f8f8f2">tcs = </span><span style="color: #f92672">new </span><span style="color: #66d9ef">TaskCompletionSource</span><span style="color: #f8f8f2">&lt;TResult&gt;();

            </span><span style="color: #66d9ef">WaitCallback
                </span><span style="color: #f8f8f2">asyncWork = _ =&gt;
                                {
                                    </span><span style="color: #f92672">try
                                    </span><span style="color: #f8f8f2">{
                                        client.ExecuteAsync&lt;T&gt;(request,
                                                               response =&gt;
                                                               tcs.SetResult(adapter.Invoke(response.Data)));
                                    }
                                    </span><span style="color: #f92672">catch </span><span style="color: #f8f8f2">(</span><span style="color: #66d9ef">Exception </span><span style="color: #f8f8f2">exc)
                                    {
                                        tcs.SetException(exc);
                                    }
                                };

            </span><span style="color: #f92672">return </span><span style="color: #f8f8f2">ExecuteTask(asyncWork, tcs);
        }

        </span><span style="color: #f92672">private static </span><span style="color: #66d9ef">Task</span><span style="color: #f8f8f2">&lt;TResult&gt; ExecuteTask&lt;TResult&gt;(</span><span style="color: #66d9ef">WaitCallback </span><span style="color: #f8f8f2">asyncWork,
                                                          </span><span style="color: #66d9ef">TaskCompletionSource</span><span style="color: #f8f8f2">&lt;TResult&gt; tcs)
        {
            </span><span style="color: #66d9ef">ThreadPool</span><span style="color: #f8f8f2">.QueueUserWorkItem(asyncWork);

            </span><span style="color: #f92672">return </span><span style="color: #f8f8f2">tcs.Task;
        }
    }
}
</span></pre>

Now I can write asynchronous code like this:

<pre style="background-color: black" class="code"><span style="color: #f92672">public </span><span style="color: #66d9ef">Task</span><span style="color: #f8f8f2"><</span><span style="color: #66d9ef">List</span><span style="color: #f8f8f2"><</span><span style="color: #66d9ef">Project</span><span style="color: #f8f8f2">>> GetAllProjects()
{
    </span><span style="color: #f92672">var </span><span style="color: #f8f8f2">request = </span><span style="color: #f92672">new </span><span style="color: #66d9ef">RestRequest </span><span style="color: #f8f8f2">{ Resource = </span><span style="color: #e6db74">"/httpAuth/app/rest/projects"</span><span style="color: #f8f8f2">, RootElement = </span><span style="color: #e6db74">"project" </span><span style="color: #f8f8f2">};
    request.AddHeader(</span><span style="color: #e6db74">"Accept"</span><span style="color: #f8f8f2">, </span><span style="color: #e6db74">"application/json"</span><span style="color: #f8f8f2">);

    </span><span style="color: #f92672">return </span><span style="color: #f8f8f2">_restClient.ExecuteTask<</span><span style="color: #66d9ef">List</span><span style="color: #f8f8f2"><</span><span style="color: #66d9ef">Project</span><span style="color: #f8f8f2">>>(request);
}
</span></pre>

So TaskCompletionSource<T> is a nice class to know about!

You might also watch this short video by [Phil Pennington](http://channel9.msdn.com/Niners/philpenn) to get a better idea about it:

<iframe style="width: 512px; height: 288px" src="http://channel9.msdn.com/Blogs/philpenn/TaskCompletionSourceTResult/player?w=512&h=288" frameborder="0" scrolling="no"></iframe>
