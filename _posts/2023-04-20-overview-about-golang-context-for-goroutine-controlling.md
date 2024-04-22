---
layout: post
title: Overview about Golang's context for Goroutine controlling
---

When you are programming using Golang, you constantly see functions and methods,
from native packages and external ones, receiving a Context interface, but many
times it is ignored by using a `context.TODO`, or just inserting the context
receiving from the caller.

I have seen this behavior a lot in many tutorials around the Internet, which
leads a new developer to despise the importance of one of the main aspects and
features of the language.

Golang's context package is essential when controlling asynchronous flows, Go
routines, timeouts, and handling requests in a robust and efficient manner. It
provides a standardized way to manage the lifecycle and behavior of concurrent
operations, ensuring graceful handling of cancellations, deadlines, and
request-scoped values.

```golang
package main

import ( 
    "context"
    "time"

    "go.mongodb.org/mongo-driver/mongo"
    "go.mongodb.org/mongo-driver/mongo/options"
)

func main() { 
    ctx := context.Background()

    client, err := mongo.Connect(ctx, options.Client().ApplyURI("mongodb://localhost:27017"))
    if err != nil {
        return
    }

    db := client.Database("database")

    // ... 
} 

```

Using it isn't hard at all, but dealing with it directly to control
concurrency operations can bring new experiences for the developer. When
spawning a new Go routine, the one who called **it is completely detached from its
child**, which means that if the father's Go routine was closed, the child
wouldn't be either.

```golang
package main

import (
    "net/http"
    "time"
)

func process() { 
    // Simulating some processing time. 
    // Theoretically, the Go routine could run indefinitely. 
}

func handler(w http.ResponseWriter, r *http.Request) { 
    go process() 
    go process()
    go process()

    // After all process invocations, the server returns, but its Go routines
    // are still live.
}

func main() { 
    mux := http.NewServeMux()

    mux.HandleFunc("GET /", handler)

    http.ListenAndServe(":8080", mux) 
}
```

Context is perfect for this situation, helping the main go routine to keep track
of its spawned ones and terminating them as necessary. It can be done in many
ways, but the most simple and widespread is by context cancellation or deadline.

In this example, the Go routines spawned by the `handler` function will stand
for a maximum of 10 seconds, even when the handler has already returned. This
behavior is perfect to limit the execution time used by a process to achieve its
goal.

> Note that we could use `sync.WaitGroup` to wait until all Go routines returned
> before continuing or returning a response to the user.

```golang
package main

import (
    "context"
    "net/http"
    "time"
)

func process(ctx context.Context) {
    // Simulating some processing time.

    // When the context is done, the process is stoped.
    select {
    case <-ctx.Done():
        return
    }
}

func handler(w http.ResponseWriter, r *http.Request) {
    ctx, _ := context.WithTimeout(r.Context(), 10*time.Second)

    go process(ctx)
    go process(ctx)
    go process(ctx)
}

func main() {
    mux := http.NewServeMux()

    mux.HandleFunc("GET /", handler)

    http.ListenAndServe(":8080", mux)
}
```

As observed, contexts can be derived from existing contexts, facilitating the
graceful termination of Go routines associated with the child context, thereby
ensuring the parent context's continuity. This derivation is called a context
tree.

![Golang's context basic
tree](https://i1.wp.com/golangbyexample.com/wp-content/uploads/2020/09/Context-Tree.jpg?resize=261%2C206&ssl=1)

<center>
    <a
        href="https://golangbyexample.com/using-context-in-golang-complete-guide">Using
        Context Package in GO (Golang) – Complete Guide</a>
</center>

When using context, the empty Context obtained from `context.Background()`
serves as the foundational root. This bare context lacks functionality on its
own, necessitating the derivation of a new context for added functionality.
Essentially, a new context is created through the encapsulation of an immutable,
pre-existing context, augmented with supplementary information.

Beyond that, context can also be used to store and propagate values through
functions and methods easily, which can be very useful in many situations,
but it is subject to another post.
