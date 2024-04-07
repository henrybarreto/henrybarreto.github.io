---
layout: post
title: O que é dyn em Rust?
description: 
    Entenda o que é dyn em Rust e como ele revoluciona o gerenciamento de memória. Saiba como Ownership e Borrowing
    garantem segurança e eficiência, além de explorar conceitos como Stack e Heap. Descubra o papel das Traits e o uso
    prático do dyn para implementações dinâmicas de Traits em tempo de execução. Uma introdução completa para novatos com
    exemplos práticos e referências úteis.
keywords: portuguese, rust, newbie, tutorial, dyn, memroia, estatico, dinamico
---

Uma dos maiores diferenciais da linguagem Rust é sua proposta para gerenciamento
de memória mais seguro e eficiente, sem o uso de [`Garbage
collector`](https://en.wikipedia.org/wiki/Garbage_collection_(computer_science))
e feito diretamente pelo compilador. Há maiores vantagens dessa linguagem, porém
esse fato já permite menor ocorrência de erros relacionados a gerenciamento de
memória, um dos mais presentes em sistemas de informação, segundo a
*[Microsoft](https://msrc-blog.microsoft.com/2019/07/18/we-need-a-safer-systems-programming-language/)*,
e com alto potencial destrutivo.

## Ownership e Borrowing

O Rust alcança esse nível de segurança em relação a memória através de duas
técnicas relativamente simples: `Ownership` e `Borrowing`.

Muito resumidamente, `Ownership` é usada pelo compilador para dar "pose" de uma
valor a um contexto, permitindo rastrear seu escopo, início e fim de uso,
liberando a memória ocupada. Já o `Borrowing` é a técnica de "emprestar" essa
"pose" a outro novo contexto, na qual invalida a pose anterior; tudo isso em
tempo de compilação.

*No vídeo abaixo, essa técnica e exemplificada de maneira bem lúdica*

<iframe width="560" height="315"
    src="https://www.youtube.com/embed/rEsoImv7vq8?si=59lCTFbSYZz_xvRc"
    title="YouTube video player" frameborder="0" allow="accelerometer; autoplay;
    clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
    referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>

- O valor é *movido* a um novo contexto, o qual ganha posse desse e fica
responsável pela liberação da memória, invalidando a posse anterior.
- O valor é *emprestado* de modo imutável para o novo contexto, permitindo
apenas a leitura deste, mantendo a pose e a responsabilidade pela liberação de
memória ao contexto que empresta. Pode haver várias referências imutáveis.
- Balão é *emprestado* de modo mutável, permitindo o novo contexto modificar
esse valor, mas ainda mantendo a pose e a responsabilidade pela liberação de
memória ao contexto que empresta. Apenas pode haver uma referência mutável.

## Stack e a Heap

Ambos os termos também tem relação com o gerenciamento de memória, mais
especificamente com o armazenamento da memória da aplicação. O `Stack` é um
espaço limitado e delimitado pelo compilador no qual dados do contexto atual com
tamanho conhecidos e ponteiros para `Heap` são armazenados, já a `Heap`,
basicamente, armazena dados com tamanho desconhecidos em tempo de compilação,
mas conhecidos em tempo de execução, e é a partir dai que o tema da postagem
ganha importância.

Imagine a seguinte situação: você está trabalhando num *crate* para fazer a
leitura de arquivos que mudam de tamanho constantemente em tempo de execução, o
que fazer? Para essa situação, um `Smart pointer` **chamado *Box*, que tem um
tipo fixo na `Stack`, **poderia ser utilizado. Esse tipo embrulha uma estrutura
de tamanho variável e aponta para a `Heap`, permitindo a alteração do tamanho
ocupado.

> Claro, tudo está bem resumido. Para informações mais precisas, consulte a
> documentação do Rust.

## Trait

> "Uma Trait é uma coleção de métodos definidos para um tipo desconhecido,
> podendo acessar outros métodos definidos no mesmo Trait"

Sabendo que estou tentando comparar o Rust com um linguagem de programação OO
tradicional, é possível dizer que os `Traits` são uma forma de compartilhar
comportamentos abstratos entre tipos de dados, como uma `interface`.

Um princípio recomendado na orientação orientada a objetos é a inversão de
dependência, o qual diz que o código não deve depender de um implementação, mas
sim de uma abstração. Isso significa que, quando se necessita que um objeto
herde certo comportamento, mas não se sabe qual classe das que herdam tal
comportamento se quer, se usa o tipo do qual os objetos herdam. Há algo
bem-parecido com o princípio de inversão de dependência no Rust utilizando
`Traits`*.*

## Finalmente... o que é dyn?

O uso prática dessa palavra reservada é até simples: o **`dyn`** é utilizado
para indicar que o tipo de uma certa estrutura precisa ser implementação de um
certo `Trait` de maneira dinâmica, em tempo de execução.

```rust

trait Service { fn do(&self); fn get(&self) {  } }

struct ServiceA { //... }

impl Service for ServiceA { fn do(&self) {  } }

fn main() { 
    // Em versões anteriores do Rust, não era necessário o uso do 'dyn'.
    // O que esse 'statemente' diz, basicamente, é: 
    // A definição 'sevice' precisa ser de um tipo que implementa o Trait Service.

    let service: Box<dyn Service> = Box::new(ServiceA::new());
}

```

Como o tamanho dos `Traits` não são conhecidos em tempo de compilação, se faz
necessário que esses `Traits` sejam envoltos em um `Smart Point`*,* que no caso
do exemplo acima é um Box, ou os usados como referências com `&`.

Sendo um pouco mais técnico, a palavra reservada `dyn` faz referência ao
`dispatch` dinâmico, já o `impl`, um outra palavra reservado do Rust, também
usada para definir herança de tipos, para o `dispatch` estático.

## Dispatch dinâmico ou estático?

Há uma pequena questão que é preciso esclarecer sobre o tema: o que são
`dispatch` dinâmico e estático? O `dispatch` dinâmico é um processo de
selecionar qual implementação chamar em tempo de execução, já o `dispatch`
estático é uma forma de polimorfismo de código que ocorre totalmente em tempo de
compilação. Esse `dispatch` descreve como uma linguagem de programão seleciona
qual implementação de um método irá ser utilizado.

> "O static dispatch vai gerar mais código, tipo generics do java, e compilar
> tudo estaticamente, enquanto dynamic dispatch acontece em tempo de execução e
> não gera esses códigos, portanto, sendo menos performático que o static
> dispatch". @jcbritogardona no Twitter, editado.

Para cada `structure` que implementa um certo `Trait` com `impl`, `dispatch`
estático, o compilador irá gerar código de substituição pras todas essas
estruturas durante a compilação, já quando o `dyn` é utilizado, o `dispatch`
dinâmico fica responsável por gerar esses códigos durante execução do código.

## Conclusão

O uso do `dyn` é relativamente simples, mas pode assustar novos programadores
por parecer introduzir um provável nível de complexidade desnecessário; já que
essa abordagem não existe em outras linguagens de programação tão no controle do
desenvolvedor.

Confesso que o tema `dispatch` ainda não sobre meu total domínio, mas como
sempre que tenho dificuldade de entender um tema nos meus estudos, irei buscar
entender e criar um pequeno resumo para tentar ajudar alguém.

Agradeço pela leitura e espero que tenha ajudado. Fique à vontade para comentar,
compartilhar ou corrigir algo; eu vou agradecer bastante.

### Referências

- [http://web.mit.edu/rust-lang_v1.25/arch/amd64_ubuntu1404/share/doc/rust/html/book/first-edition/the-stack-and-the-heap.html](http://web.mit.edu/rust-lang_v1.25/arch/amd64_ubuntu1404/share/doc/rust/html/book/first-edition/the-stack-and-the-heap.html)
- [https://doc.rust-lang.org/book/ch10-02-traits.html](https://doc.rust-lang.org/book/ch10-02-traits.html)
- [https://doc.rust-lang.org/std/keyword.dyn.html](https://doc.rust-lang.org/std/keyword.dyn.html)
- [https://doc.rust-lang.org/edition-guide/rust-2018/trait-system/dyn-trait-for-trait-objects.html](https://doc.rust-lang.org/edition-guide/rust-2018/trait-system/dyn-trait-for-trait-objects.html)
- [https://www.educative.io/edpresso/what-is-the-dyn-keyword-in-rust](https://www.educative.io/edpresso/what-is-the-dyn-keyword-in-rust)
- [https://en.wikipedia.org/wiki/Dynamic_dispatch](https://en.wikipedia.org/wiki/Dynamic_dispatch)
- [https://en.wikipedia.org/wiki/Static_dispatch](https://en.wikipedia.org/wiki/Static_dispatch)
- [https://medium.com/ingeniouslysimple/static-and-dynamic-dispatch-324d3dc890a3](https://medium.com/ingeniouslysimple/static-and-dynamic-dispatch-324d3dc890a3)
- [https://doc.rust-lang.org/std/keyword.impl.html](https://doc.rust-lang.org/std/keyword.impl.html)
- [https://doc.rust-lang.org/rust-by-example/generics/impl.html](https://doc.rust-lang.org/rust-by-example/generics/impl.html)
