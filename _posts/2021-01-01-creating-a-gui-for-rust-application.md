---
layout: post
title: Creating a GUI for a Rust application
---

I suppose the majority of beginner programmers aspire to create something
amazing and popular, and perhaps, become famous and wealthy at some point.
However, when they begin, the "black screen" of a terminal doesn't seem like the
next Facebook. So, what should you do if you want to build a more user-friendly
desktop application? You build an application with a Graphical User Interface
(GUI)!

To create the visual interface without working directly inside the code, which
can be just a bunch of statements, we will use an application called Glade.
Glade allows us to easily build GTK UIs by simply dragging and dropping
components, generating XML with information about the components, positions, and
other details of our interface.

The required crates are GTK and GIO. You can add them to your Cargo.toml file
like this:

```toml

[dependencies.gtk] 
version = "0.9.0"
features = ["v3_16"]

[dependencies.gio] 
version = ""
features = ["v2_44"]

```

The example application we will build is called Name This Color. With it, the
user can choose a color and give it a name of their preference. It's simple, but
explainable.

So, let's take a look at the NTC interface. The XML representation may seem like
too much, but let's see it as humans should:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!-- Generated with glade 3.22.2 -->
<interface>
  <requires lib="gtk+" version="3.20"/>
  <object class="GtkWindow" id="main_window">
    <property name="width_request">450</property>
    <property name="height_request">300</property>
    <property name="can_focus">False</property>
    <property name="title" translatable="yes">Name this color</property>
    <property name="resizable">False</property>
    <property name="window_position">center</property>
    <child type="titlebar">
      <placeholder/>
    </child>
    <child>
      <object class="GtkFixed">
        <property name="width_request">450</property>
        <property name="height_request">300</property>
        <property name="visible">True</property>
        <property name="can_focus">False</property>
        <child>
          <object class="GtkEntry" id="color_name_entry">
            <property name="name">color_name_entry</property>
            <property name="width_request">166</property>
            <property name="height_request">40</property>
            <property name="visible">True</property>
            <property name="can_focus">True</property>
          </object>
          <packing>
            <property name="x">145</property>
            <property name="y">170</property>
          </packing>
        </child>
        <child>
          <object class="GtkColorButton" id="color_selection">
            <property name="name">color_selection</property>
            <property name="width_request">100</property>
            <property name="height_request">80</property>
            <property name="visible">True</property>
            <property name="can_focus">True</property>
            <property name="receives_default">True</property>
          </object>
          <packing>
            <property name="x">175</property>
            <property name="y">45</property>
          </packing>
        </child>
        <child>
          <object class="GtkLabel" id="select_color_label">
            <property name="name">select_color_label</property>
            <property name="width_request">100</property>
            <property name="height_request">34</property>
            <property name="visible">True</property>
            <property name="can_focus">False</property>
            <property name="label" translatable="yes">Select a color</property>
          </object>
          <packing>
            <property name="x">175</property>
            <property name="y">10</property>
          </packing>
        </child>
        <child>
          <object class="GtkButton" id="save_button">
            <property name="label" translatable="yes">Save</property>
            <property name="name">save_button</property>
            <property name="width_request">100</property>
            <property name="height_request">40</property>
            <property name="visible">True</property>
            <property name="can_focus">True</property>
            <property name="receives_default">True</property>
          </object>
          <packing>
            <property name="x">175</property>
            <property name="y">250</property>
          </packing>
        </child>
        <child>
          <object class="GtkLabel" id="name_color_label">
            <property name="name">name_color_label</property>
            <property name="width_request">100</property>
            <property name="height_request">41</property>
            <property name="visible">True</property>
            <property name="can_focus">False</property>
            <property name="label" translatable="yes">Name this color</property>
          </object>
          <packing>
            <property name="x">175</property>
            <property name="y">135</property>
          </packing>
        </child>
        <child>
          <object class="GtkLabel" id="registered_color_label">
            <property name="name">registered_color_label</property>
            <property name="width_request">120</property>
            <property name="height_request">25</property>
            <property name="can_focus">False</property>
          </object>
          <packing>
            <property name="x">165</property>
            <property name="y">215</property>
          </packing>
        </child>
      </object>
    </child>
  </object>
</interface>
```

And here's how it appears to a human:

![Captura de tela de 2020-12-31
19-06-22.png](https://cdn.hashnode.com/res/hashnode/image/upload/v1609452598189/3gJD3xvWS.png)

> What does it do?

It's quite simple. We'll capture the selected color in RGBA format and its name,
then save it in a structure that has two vectors: one for names and another for
colors, which is another structure defined with red, green, blue, and alpha
fields. Afterwards, we'll push the captured name and color to the structure.

Let's see the code, as it's often the best explanation:

```rust
// src/ntc.rs
#[derive(Debug, PartialEq)]
pub struct Color {
    pub red: f64,
    pub green: f64,
    pub blue: f64,
    pub alpha: f64
}
pub struct NTC {
  pub names: Vec<String>,
  pub colors: Vec<Color>
}
impl NTC {
  pub fn new() -> Self {
    NTC {
      names: vec![],
      colors: vec![]
    }
  }
  pub fn save_color(&mut self, color: Color, name: String) -> Result<(), String> {
    if self.colors.contains(&color) || self.names.contains(&name) {
      Err("The color was already saved!".to_string())
    } else {
      self.colors.push(color);
      self.names.push(name);
      Ok(())
    }
  }
}
```

The main code will be self explained:

```rust
// src/main.rs
use std::{cell::RefCell, path::Path, rc::Rc};

// gtk needs
use gtk::prelude::*;
use gio::prelude::*;

use ntc::Color;

mod ntc; // importing the ntc module

fn main() {
    gtk::init() // This function will initialize the gtk
    .expect("Could not init the GTK"); 
    // and if something goes wrong, it will send this message

    /*
    The documentation says about gtk::init and gtk::Application::new:
    "When using Application, it is not necessary to call gtk_init manually. 
    It is called as soon as the application gets registered as the 
    primary instance".
    It worth to check it.
    */

    // Here it defined a gtk application, the minimum to init an application
    // There are some caveats about this
    /*
       To build this interface, I have used a component GtkWindow as father of from
       all others components, hence, it needed to create Gtk::Application inside
       de code.

       If a GtkApplicationWindow had been to choose, it would not be necessary, 
       because it alraedy had a Gtk::Applicaiton "inside".
   */
    let application = gtk::Application::new(
        Some("dev.henrybarreto.name-this-color"), // Application id
        Default::default() // Using default flags
    ).expect("Could not create the gtk aplication");

    // The magic happens in this line
    // The ntc.glade is pushed into our code through a builder.
    // With this builder it is possible to get all components inside the XML from Glade
    let builder: gtk::Builder =  gtk::Builder::from_file(Path::new("ntc.glade"));

    // ----------------------------------------------------------|
    let colors_saved = Rc::new(RefCell::new(ntc::NTC::new()));// |
    // ----------------------------------------------------------|

    // when the signal connect_activate was sent, the application will get our
    // components for work
    application.connect_activate(move |_| {
        // All components from the ntc.glade are imported, until the one has not used to
        // for didactic propouses
        // the "method" get_object gets from the id.
        let main_window: gtk::Window = builder.get_object("main_window").expect("Could not get the object main_window");
        let save_button: gtk::Button = builder.get_object("save_button").expect("Could not get the save_button");
        let color_selection: gtk::ColorButton = builder.get_object("color_selection").expect("Could not get the color_selection");
        let color_name_entry: gtk::Entry = builder.get_object("color_name_entry").expect("Could not get the color_name_entry");
        //let _select_color_label: gtk::Label = builder.get_object("select_color_label").expect("Could not get the select_color_label");
        //let _name_color_label: gtk::Label = builder.get_object("name_color_label").expect("Could not get the name_color_label");
        let registered_color_label: gtk::Label = builder.get_object("registered_color_label").expect("Could not get the registeredd_color_label");

        let colors_saved = colors_saved.clone();
	
        // When the button was clicked...
        // The "main" logic happen here
        save_button.connect_clicked(move |_| {
            let color_rgba = color_selection.get_rgba(); // getting the color from the button
            let color: Color = Color { // setting manually color by color for didactic.
                red: color_rgba.red,
                green: color_rgba.green,
                blue: color_rgba.blue,
                alpha: color_rgba.alpha
            };
            let name = color_name_entry.get_text().to_string(); // getting name from the entry

            registered_color_label.set_visible(true); // Letting the label visible
            if let Ok(()) = colors_saved.borrow_mut().save_color(color, name) { // if the color is saved correctly
                registered_color_label.set_text("Registered!");
            } else { // when does it not
                registered_color_label.set_text("Already Registered!");
            }
        });

        // "event" when the close button is clicked
        main_window.connect_destroy(move |_|  
        // the gtk application is closed
            gtk::main_quit(); 
        });

        main_window.show(); // showing all components inside the main_window
    });

    application.run(&[]); // initializing the application
    gtk::main(); // initializing the gtk looping
}
```

One important detail in this code is the use of Rc and RefCell. Given Rust's
memory management system, moving a variable definition through a Fn trait
function isn't a good idea and isn't allowed by the compiler.

## Rc and RefCell

Rc is used in Rust to enable a single value to have multiple owners. On the
other hand, RefCell holds a single value with mutable borrowing rules checked at
runtime, allowing for multiple immutable borrows. In our application, I've used
these concepts to create an outer NTC struct, capture the color and name within
a closure, and save it through a mutable reference to this outer structure.

The project structure looks like this:

```bash

.
├── Cargo.lock
├── Cargo.toml
├── ntc.glade
└── src
    ├── main.rs
    └── ntc.rs

```

Simple, isn't it? How does the application look?

![Captura de tela de 2020-12-31
19-07-12.png](https://cdn.hashnode.com/res/hashnode/image/upload/v1609452571873/kdTcDGAjy.png)

When a new entry is added:

![Captura de tela de 2020-12-31
19-12-24.png](https://cdn.hashnode.com/res/hashnode/image/upload/v1609452796290/DLurrnicB.png)

When either the color or name already exists in the "database":

![Captura de tela de 2020-12-31
19-12-36.png](https://cdn.hashnode.com/res/hashnode/image/upload/v1609452809510/yZekQaJ8p.png)

Thank you for reading! Feel free to leave comments, corrections, or just say hi.
I hope it helps someone.

## Useful links

- [https://gtk-rs.org/docs-src/tutorial/glade](https://gtk-rs.org/docs-src/tutorial/glade)
- [https://gtk-rs.org/](https://gtk-rs.org/)
- [https://doc.rust-lang.org/book/ch15-05-interior-mutability.html](https://doc.rust-lang.org/book/ch15-05-interior-mutability.html)
- [https://www.reddit.com/r/rust/comments/755a5x/i_have_finally_understood_what_cell_and_refcell/](https://www.reddit.com/r/rust/comments/755a5x/i_have_finally_understood_what_cell_and_refcell/)
