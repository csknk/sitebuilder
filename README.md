Static Site Generator
=====================
This static site generator uses Make and Pandoc on Linux to generate a simple static site.

It turns markdown files into HTML. Math formulae in LaTeX are handled, so you can write this kind of thing:

If $a = p^n$ is a prime power then $Ø(p^n) = p^n - p^{n - 1}$

...and it will display like this in your HTML:

![Image showing formula](eulers-totient-function.png?raw=true "Euler's totient function")

Why?
----
There are loads of great static site builders out there: Jekyll, Zola, Vuepress etc but I need something that is:

1. Super simple and easy to maintain
2. Able to handle LaTeX easily
3. Stable - I don't want to worry about broken builds because of Ruby versions or whatever

I need a simple static site builder to manage technical notes.

I don't want to go down the road of learning complicated configs in languages and stacks that I don't work in. I like C, C++ and I want to improve my Make skills, so I built this.

What Stage is it At?
--------------------
At the moment it's a very basic proof of concept and work in progress.

You change styles by editing a css file and compressing this to `assets/compressed-style.css`. Use the `compress-css.sh` script for this for the time being (I plan to build this into the make process).

I plan to add custom header and footer html files.
