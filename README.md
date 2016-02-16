# RAILS REFACTOR
--------------
Basic renames and refactorings for rails projects.
Although these are not perfect, they'll do a lot of the work for you 
and save you time. 

Before using, recommend that you start from a clean repository state so 
you can easily review changes.

To install:
  gem install rails_refactor

Before use, make sure you cd to the root of your rails project.

To rename a controller:
  $ rails_refactor rename OldController NewController 

* renames controller file & class name in file
* renames controller spec file & class name in file
* renames view directory
* renames helper file & module name in file
* updates routes

To rename a controller action:
  $ rails_refactor rename DummyController.old_action new_action

* renames controller action in controller class file
* renames view files for all formats

To rename a model:
  $ rails_refactor rename OldModel NewModel

* renames model file & class name in file
* renames spec file & class name in file
* renames migration & class name & table names in file

Please note that if you want to run the tests, clone the repo from github, rather than using the gem (tests rely on git). Next cd to the 'dummy' rails project directory.
  $ ../lib/rails_refactor.rb test

More refactorings coming soon... Please fork and contribute :-)

Started by James Crisp & Ryan Bigg pairing at RORO hack night 24 Nov 2010.
Thanks to Andrew Snow for help with Gemification.

Thanks to Tricon for some improvements and start on TextMate Bundle:
https://github.com/Tricon/rails-refactor.tmbundle

