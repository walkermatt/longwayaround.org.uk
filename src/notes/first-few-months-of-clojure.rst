First few months of Clojure
###########################
:date: 2014-02-18 19:42
:category: notes
:tags: command-line, clojure, notes

I've been learning a bit of Lisp on and off for a few years, I first read (about half of) `Land of Lisp <http://landoflisp.com/>`_, then `Practical Lisp <http://www.gigamonkeys.com/book/>`_ then I came across `Clojure <http://clojure.org/>`_ a modern Lisp that runs on the JVM and since I've been reading `Clojure Programming <http://www.clojurebook.com/>`_ and working through `koans <https://github.com/walkermatt/clojure-koans>`_ and `katas <https://github.com/walkermatt/yellow_belt_clojure_katas>`_.

I've also built a small Clojure library and command-line app `GridRef <https://github.com/walkermatt/gridref>`_ to convert between an Ordnance Survey GB grid reference and British National Grid coordinates. While I was at it I built a web API `GridRef Web <https://github.com/walkermatt/gridref-web>`_ which exposes the conversion functions via a `Ring <https://github.com/ring-clojure/ring>`_ web app, hosted on Heroku and available at `http://gridref.longwayaround.org.uk/ <http://gridref.longwayaround.org.uk/>`_. Having a real (all be it small) project to work on has helped massively in learning and while I found the move from Python and JavaScript initially challenging I'm finding that I'm now thinking more functionally elsewhere.

A few months in I'm really enjoying working with Clojure which feels like a thoughtfully designed language that incorporates sound theory in a practical way. The way the language and tooling favour interactive development really suits (especially `lein <https://github.com/technomancy/leiningen>`_ and `vim-fireplace <https://github.com/tpope/vim-fireplace>`_) and I'm really drawn to the Lisp everything is an expression and code-as-data principles.

What little contact I've had with the community as been positive, it feels like a community of bright individuals from a range of backgrounds which give it enthusiasm and a healthy balance.

I was a bit hesitant of it being hosted on the JVM at first and it does suffer in places from the "window into hell" syndrome where you are exposed to the guts of the implementation but the infrastructure provided by the JVM seems to largely make up for this.

I'm sure Clojure is likely to my language of choice for a while, I'm now looking forward to getting on to exploring some of it's key features such as concurrency which I've only scratched the surface of so far.

Resources
---------

Some links to resources I've found useful or interesting while learning the basics:

* `Learn Clojure in Y minutes <http://learnxinyminutes.com/docs/clojure/>`_ - very brief overview of the language basics by example
* `Leiningen <https://github.com/technomancy/leiningen>`_ - installing Leiningen will set up a sane Clojure enviroment for you and provide access to a Clojure Read Eval Print Loop via ``lein repl``
* `ClojureDocs <http://clojuredocs.org>`_ - community documentation site
* `Clojure for the Brave and True <http://www.braveclojure.com/>`_ -  witty book for beginners
* `Yellow belt Clojure katas <https://github.com/walkermatt/yellow_belt_clojure_katas>`_ - a handful of small exercises to learn from
* `Clojure Koans <https://github.com/walkermatt/clojure-koans>`_ - a much more extensive set of exercises
* `reddit.com/r/clojure <http://reddit.com/r/clojure>`_ - Clojure community on Reddit
* `Intro to Clojure <https://github.com/walkermatt/clojure-intro>`_ - brief intro based on learnxinyminutes.com/docs/clojure
