---
layout: post
title: Documenting your API with OpenAPI standard
---

## What is OpenAPI?

[OpenAPI standard](https://oai.github.io/Documentation/start-here.html) is the
most  broadly adopted industry standard for describing new, and old, APIs.
Through it, you can describe which are your routes, its HTTP methods, headers,
bodies, responses, information to access and more. It is worth to say the
OpenAPI standards cannot describe any kind of API, it has its limitations.

## Advances of OpenAPI

According to the getting started of [OpenAPI
Initiative](https://oai.github.io/Documentation/start-here.html#advantages-of-using-openapi),
using the standard to describe an API empowers you to do the following topics:

- **Description Validation and Linting**: Check that your description file is
syntactically correct and adheres to a specific version of the Specification and
the rest of your team’s formatting guidelines.
- **Data Validation**: Check that the data flowing through your API (in both
directions) is correct, during development and once deployed.
- **Documentation Generation**: Create traditional human-readable documentation
based on the machine-readable description, which always stays up-to-date.
- **Code Generation**: *Create both server and client code* in any programming
language, freeing developers from having to perform data validation or write SDK
glue code, for example.
- **Graphical Editors**: Allow easy creation of description files using a GUI
instead of typing them by hand.
- **Mock Servers**: Create fake servers providing example responses, which you
and your customers can start testing with before you write a single line of
code.
- **Security Analysis**: Discover possible vulnerabilities at the API design
stage instead of much, much later.

## OpenAPI best practices

There is a sequence of recommendations given by OpenAPI initiative to build
better specification documents. They are: [use a Design-First
Approach](https://oai.github.io/Documentation/best-practices.html#use-a-design-first-approach),
[Keep a Single Source of
Truth](https://oai.github.io/Documentation/best-practices.html#keep-a-single-source-of-truth),
****[Add OpenAPI Documents to Source
Control](https://oai.github.io/Documentation/best-practices.html#add-openapi-documents-to-source-control),
[Make the OpenAPI Documents Available to the
Users](https://oai.github.io/Documentation/best-practices.html#make-the-openapi-documents-available-to-the-users),
[There is Seldom Need to Write OpenAPI Documents by
Hand](https://oai.github.io/Documentation/best-practices.html#there-is-seldom-need-to-write-openapi-documents-by-hand)
and [Working with Big
Documents](https://oai.github.io/Documentation/best-practices.html#working-with-big-documents).
Check each one following the link.

## OpenAPI Tools

There are countless great tools to work with this standard, what you can check
[here](https://openapi.tools/), but I’ll show to you just those what have a
better fit with my working flow. Those tools are:

### **Redocly CLI**

This tool helps you to **lint** files, **join**, **bundle** and **split** them.
I’ve chosen it because it allowed me to don’t repeat myself, splitting the
specification into many files with parameters, responses, models and so on. You
can also join two different versions of a specification to enable the release of
private and public versions of the API, for example, and **preview** your
specification through the browser.

*The Redocly has a great extension what provides a language server to help you
to work with the OpenAPI kind of files. If you use vim/neovim with coc.nvim,
I’ve built a simple extension to enable the Redocly extension to work with it.*

Check the tool here:
[https://redocly.com/docs/cli/](https://redocly.com/docs/cli/)

### **Prism CLI**

The [Prism CLI](https://meta.stoplight.io/docs/prism/ZG9jOjk0-prism-cli)
provides a way for you to create a mock server, proxy to the real API, following
the definition and patterns set on the specification file, and linting, as the
Redocly CLI. The mock process is important, for example, when you don’t have the
real API implemented and need to test it. Proxy process helps you to guarantee
the real API is implemented as the specified.

Prism also have a
[client](https://meta.stoplight.io/docs/prism/ZG9jOjE2MDY1Njcw-prism-client)
what could be used to mock and proxy the API too, allowing to create integration
and contract tests, everything from the OpenAPI specification file. I,
personally, didn’t do that yet, but it is the next step to implement. I believe
I’ll document my experience with it, too.

Check the tool here:
[https://meta.stoplight.io/docs/prism/ZG9jOjk0-prism-cli](https://meta.stoplight.io/docs/prism/ZG9jOjk0-prism-cli)

### **OpenAPI Generator**

You’ve learned about the standard, read about the best practices, used tools to
build your API documentation, and now you can to generate a server or client;
that is the why of [OpenAPI
Generator](https://github.com/OpenAPITools/openapi-generator). This tool gets as
entry the bundled OpenAPI file and generate the client or the server for the
language/framework you defined.

It’ll provide to you a fully functional, depending on what generator you’ve
chosen, a client layer, to send requests to the API sever, or a server layer to
receive those requests. The tool isn’t perfect, some generators doesn’t have
some features, what makes it important to select the generator carefully.

## Postman and Insomnia

When your specification is ready, you can use it with other tools to test your
API. In addition to what I said about Prism client, mock and proxy from a
OpenAPI file, you can load that specification file to a tool like Postman or
insomnia to enable you to test any requests manually, when necessary.

Check the tool here:
[https://github.com/OpenAPITools/openapi-generator](https://github.com/OpenAPITools/openapi-generator)

## Swagger

It isn’t possible to talk about OpenAPI without mention Swagger and its tools.
As its websites says: swagger is a set of open-source tools built around the
OpenAPI Specification that can help you to design, build, document and consume
REST APIs.

[Swagger](https://swagger.io/docs/specification/about/) contains three greats
tools to work with the specification: [Swagger
UI](https://github.com/swagger-api/swagger-ui), [Swagger
Editor](https://editor.swagger.io/) and [Swagger
Codegen](https://github.com/swagger-api/swagger-codegen). The Swagger UI renders
OpenAPI specs as interactive API documentation, Swagger Editor is a
browser-based editor where you can write OpenAPI specs and Swagger Codegen
generates server stubs and client libraries from an OpenAPI spec like the
OpenAPI generator.

## Conclusion

I believe it can empower you to improve your API service in many points. It
helps you to check the API’s viability before code anything, saving time,
efforts and money, document when the API already exist, expose to public your
routes and test to guarantee the API’s stability throughout changes and much
more.

That has been my experience using the OpenAPI standard; I’m still on the
beginning of the journey, and I have a lot to learn and to do yet. However, I
think that experience could help someone to speed up its process to build
OpenAPI specification and understand how powerful it is.

Thank you for reading. If you have any feedback; I’d appreciate so much, as one
of the goals from that post is to document what I’ve learned and help someone
else over the process.
