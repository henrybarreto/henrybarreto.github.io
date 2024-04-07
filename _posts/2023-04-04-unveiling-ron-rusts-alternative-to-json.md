---
layout: post
title: Unveiling RON, Rust's alternative to JSON
description:
    Discover the limitations of JSON in Rust and how RON (Rust Object Notation) overcomes them. Learn about RON's seamless
    support for Rust data types, enhanced readability with features like trailing commas and comments, and differentiation
    between data structures. Explore examples and resources to leverage RON effectively in your Rust projects.
keywords: rust, json, ron, serialization, data interchange, rust ecosystem
---

The majority of developers know about JSON, JavaScript Object Notation, and its
utility in everyday life. However, as the 'J' in the name implies, JSON was
originally intended to be used in JavaScript, which means its limitations too.

A good example is from Rust, as a strongly typed language, suffers a bit from
the incompatibility of types in a JSON object, although the communities have
already solved the problems of parsing JSON to Rust's through the crates.

> It doesn't differentiate a floating number from an integer one, for example.

This is an example from the `serde_json`, a crate used to perform JSON
operations in Rust.

```rust
use serde::{Deserialize, Serialize};
use serde_json::Result;

#[derive(Serialize, Deserialize)]
struct Person {
    name: String,
    age: u8,
    phones: Vec<String>,
}

fn typed_example() -> Result<()> {
    // Some JSON input data as a &str. Maybe this comes from the user.
    let data = r#"
        {
            "name": "John Doe",
            "age": 43,
            "phones": [
                "+44 1234567",
                "+44 2345678"
            ]
        }"#;

    // Parse the string of data into a Person object. This is exactly the
    // same function as the one that produced serde_json::Value above, but
    // now we are asking it for a Person as output.
    let p: Person = serde_json::from_str(data)?;

    // Do things just like with any other Rust data structure.
    println!("Please call {} at the number {}", p.name, p.phones[0]);

    Ok(())
}
```

As we can see, the parsing from JSON just works, but it has some issues like
non-differentiations between structures and maps, random order, or quoted
fields. In order to solve these issues and others, RON comes into the field.

## What is a RON?

A RON, what stands for Rust Object Notation, is the Rust version of JSON,
designed to support all of Rust data, so structs, enums, tuples, arrays, generic
maps, and primitive values, but it also its
[limitations](https://github.com/ron-rs/ron?tab=readme-ov-file#limitations).

This is an example of JSON and RON objects.

### JSON

```json
{
   "materials": {
        "metal": {
            "reflectivity": 1.0
        },
        "plastic": {
            "reflectivity": 0.5
        }
   },
   "entities": [
        {
            "name": "hero",
            "material": "metal"
        },
        {
            "name": "monster",
            "material": "plastic"
        }
   ]
}
```

### RON

```rust
Scene( // class name is optional
    materials: { // this is a map
        "metal": (
            reflectivity: 1.0,
        ),
        "plastic": (
            reflectivity: 0.5,
        ),
    },
    entities: [ // this is an array
        (
            name: "hero",
            material: "metal",
        ),
        (
            name: "monster",
            material: "plastic",
        ),
    ],
)
```

Note the following advantages of RON over JSON:

- Trailing commas are allowed.
- Single- and multi-line comments.
- Field names aren't quoted, so it's less verbose.
- Optional struct names improve readability.
- Enums are supported (and less verbose than their JSON representation).
- Comments.

> The new format uses `(`..`)` brackets for heterogeneous structures (classes),
> while preserving the `{`..`}` for maps, and `[`..`]` for homogeneous
> structures (arrays). This distinction allows us to solve the biggest problem
> with JSON.

In the RON's [repository](https://github.com/ron-rs/ron) has some
[examples](https://github.com/ron-rs/ron/tree/master/examples) to view and try
out, further information about the crate, tooling around and much more what you
need to know about it.

In summary, RON (Rust Object Notation) emerges as a superior alternative to
JSON, specifically tailored for Rust's needs. Unlike JSON, RON supports Rust's
data types seamlessly and offers enhancements like trailing commas and comments
for improved readability. Its ability to differentiate between various data
structures resolves key limitations of JSON. With RON, Rust developers gain a
more efficient and expressive tool for data serialization and interchange,
promising enhanced productivity and code maintainability in the Rust ecosystem.
