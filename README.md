Static Site Generator
=====================
This static site generator uses Make and Pandoc on Linux to generate a simple static site.

It turns markdown files into HTML. Math formulae in LaTeX are handled, so you can write this kind of thing:

If $a = p^n$ is a prime power then $Ø(p^n) = p^n - p^{n - 1}$

...and it will display like this in your HTML:

![Image showing formula](eulers-totient-function.png?raw=true "Euler's totient function")

Pandoc does the heavy lifting and converts LaTeX in your markdown to this monster in your HTML:

```html
<p>
If
<math display="inline" xmlns="http://www.w3.org/1998/Math/MathML"><semantics><mrow><mi>a</mi><mo>=</mo><msup><mi>p</mi><mi>n</mi></msup></mrow><annotation encoding="application/x-tex">a = p^n</annotation></semantics></math>
 is a prime power then
<math display="inline" xmlns="http://www.w3.org/1998/Math/MathML"><semantics><mrow><mi>Ø</mi><mo stretchy="false" form="prefix">(</mo><msup><mi>p</mi><mi>n</mi></msup><mo stretchy="false" form="postfix">)</mo><mo>=</mo><msup><mi>p</mi><mi>n</mi></msup><mo>−</mo><msup><mi>p</mi><mrow><mi>n</mi><mo>−</mo><mn>1</mn></mrow></msup></mrow><annotation encoding="application/x-tex">Ø(p^n) = p^n - p^{n - 1}</annotation></semantics></math>
</p>
```


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
At the moment it's a very fairly basic proof of concept and work in progress. It's a handy tool that I use to convert markdown notes into websites.

All Markdown files in the `src` directory are processed by `pandoc` into HTML files. The resulting HTML includes a header and footer template: `templates/header.html` and `templates/footer.html`.

A YAML collection of file names and their relative URLs is created at `data/nav.yaml`. This is used to build a basic menu of links to all files in the directory.

Change styles by editing `assets/style.css`. This is compressed during the build. Add JavaScript to `assets/index.js`. CSS and JavaScript assets are given a unique hash during the build process to act as a cache buster.

At the moment, JavaScript is not compressed because:

* Compressing JavaScript (especially ES6) is complicated
* This is for basic display of primarily textual data in HTML format, so tons of JS are not really necessary.

Site Metadata
-------------
Set metadata in `data/config.yaml`. Currently only the `title` and `author` fields are used, but it would be easy to extend the HTML templates to make use of more metadata.

Can I Deploy the Built HTML files?
----------------------------------
Yes. You could use `rsync` to copy them to a public web directory.
