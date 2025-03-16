---
layout: post
title: Overview about Golang's context for Goroutine controlling
---

When programming in Go, you frequently encounter functions and methods—both from
native packages and third-party libraries—that accept a `context.Context` as an
argument. However, it's common to see this context often ignored, either by
using `context.TODO()` or simply passing along the context received from the
caller.

This behavior is prevalent in many tutorials across the internet, which can lead
new developers to overlook the importance of one of Go's most powerful features:
the `context` package.

The `context` package is crucial for managing asynchronous workflows,
goroutines, timeouts, and handling requests in a robust and efficient manner. It
provides a standardized way to manage the lifecycle of concurrent operations,
ensuring graceful handling of cancellations, deadlines, and request-scoped
values.

### Basic Example

Let's look at a simple example of how a `Context` is used:

```golang
package main

import (
    "context" "time" "go.mongodb.org/mongo-driver/mongo"
    "go.mongodb.org/mongo-driver/mongo/options"
)

func main() {
    ctx := context.Background()

    client, err := mongo.Connect(ctx, options.Client().ApplyURI("mongodb://localhost:27017")) 
    if err != nil { 
        return
    }

    db := client.Database("database")

    // Further operations... 
}
```

Using context isn't difficult, but it’s important to understand how it helps
manage goroutines and concurrency. For instance, when spawning a new goroutine,
the calling function is *completely detached* from its child goroutines. This
means that if the parent goroutine exits, the child goroutines won't
automatically stop.

### Problem with Detached Goroutines

Consider the following example of spawning goroutines in an HTTP handler:

```golang
package main

import ( 
    "net/http"
    "time"
)

func process() {
    // Simulating some processing time. 
    // This goroutine could theoretically run indefinitely.
}

func handler(w http.ResponseWriter, r *http.Request) {
    go process()
    go process()
    go process()

    // After all process invocations, the server responds,
    // but the goroutines continue running in the background. 
}

func main() { 
    mux := http.NewServeMux() 
    mux.HandleFunc("/", handler)

    http.ListenAndServe(":8080", mux) 
}
```

In this example, the `handler` function spawns three goroutines, but after
returning the response to the client, these goroutines continue running,
potentially indefinitely.

This is where the `context` package shines.

### Using Context for Goroutine Management

The `context` package is designed to help control and manage the behavior of
these goroutines. One of its primary uses is to enable cancellation or setting
timeouts for concurrent operations. By passing a context to each goroutine, we
can ensure that these tasks are gracefully terminated when necessary.

Here’s an improved version of the previous example, which adds a timeout for the
spawned goroutines:

```golang
package main

import (
    "context"
    "net/http"
    "time"
)

func process(ctx context.Context) {
    // Listen for context cancellation.
    select {
    case <-ctx.Done():
        return 
    default:
        // Simulating some processing time.
    }
}

func handler(w http.ResponseWriter, r *http.Request) {
    // Set a timeout of 10 seconds for the spawned goroutines.
    ctx, cancel := context.WithTimeout(r.Context(), 10*time.Second)
    defer cancel()

    go process(ctx)
    go process(ctx)
    go process(ctx) 
}

func main() {
    mux := http.NewServeMux()
    mux.HandleFunc("/", handler)

    http.ListenAndServe(":8080", mux) 
}
```

In this version, the `handler` creates a new context with a 10-second timeout
using `context.WithTimeout`. When the timeout is reached, all the goroutines
spawned by that handler will be cancelled, even if they haven’t completed their
work.

> **Note:** You could also use `sync.WaitGroup` to ensure that all goroutines
> complete before responding to the client. However, this is outside the scope
> of this example.

### Context Tree

In Go, contexts are often derived from other contexts, creating a "context tree"
that helps track and manage the lifecycle of goroutines. The context from
`context.Background()` serves as the root of the tree, and derived contexts
inherit its properties while adding their own specific features.

For instance, a child context could have a timeout or a cancellation function,
and cancelling the child context will automatically propagate to its children.

![Context Tree in Go](https://i1.wp.com/golangbyexample.com/wp-content/uploads/2020/09/Context-Tree.jpg?resize=261%2C206&ssl=1)

<center> <a href="https://golangbyexample.com/using-context-in-golang-complete-guide"> Using Context Package in Go (Golang) – Complete Guide </a> </center>

### Storing and Propagating Values

In addition to managing concurrency, the `context` package can be used to
propagate values through the call chain. For example, it’s common to store
request-scoped data (such as user information or request IDs) in the context,
making it accessible to all functions and methods in the chain.

However, this is a topic that warrants its own discussion.
