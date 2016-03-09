[![Build Status](https://img.shields.io/travis/nickdowse/rails_magic_renamer.svg)](https://travis-ci.org/nickdowse/rails_magic_renamer)

# RAILS MAGIC RENAMER

This repository is currently a work in progress, until the time that it's ready check out [https://github.com/jcrisp/rails_refactor](https://github.com/jcrisp/rails_refactor) for the original work.

Basic renames and refactorings for rails projects.
Although these are not perfect, they'll do a lot of the work for you 
and save you time. 

Before using, recommend that you start from a clean repository state so 
you can easily review changes.

To install:
  gem install rails_magic_renamer

Before use, make sure you cd to the root of your rails project.

To rename a controller open up `rails console` and run:
  \> RailsMagicRenamer::Renamer.new("from_model", "to_model").rename

This will:

* rename the controller file & class name in file
* rename the controller spec file & class name in file
* rename the view directory
* rename the helper file & module name in file
* updates routes
* rename the model file & class name in file
* rename the spec file & class name in file
* rename the migration & class name & table names in file

Started by James Crisp & Ryan Bigg pairing at RORO hack night 24 Nov 2010.
Thanks to Andrew Snow for help with Gemification.

Thanks to Tricon for some improvements and start on TextMate Bundle:
https://github.com/Tricon/rails-refactor.tmbundle

Any questions open an issue or hit me up on Twitter: [@nmdowse](https://twitter.com/nmdowse).
