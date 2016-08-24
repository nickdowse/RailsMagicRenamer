[![Build Status](https://img.shields.io/travis/nickdowse/rails_magic_renamer.svg)](https://travis-ci.org/nickdowse/rails_magic_renamer) 
[![Test Coverage](https://codeclimate.com/github/nickdowse/rails_magic_renamer/badges/coverage.svg)](https://codeclimate.com/github/nickdowse/rails_magic_renamer/coverage)
  

# RAILS MAGIC RENAMER

Rails Magic Renamer is a gem for renaming rails models in a project. As your product evolves and changes you realise that the old name you had for a model no longer makes sense, and so it should be renamed. Previously this has been a big hassle, involving lots of finding and replacing, specifying of foreign keys, table names, and you always miss something. This gem aims to automate that entire process in a set and forget manner. You pass in the name of the model you want to rename (eg 'Post'), the name you want it to be renamed to (eg 'Article'), call rename and then sit back and relax.

First of all the gem will commit all working changes so that it starts from a clean slate. From there it will rename files, rename models, update relationships, rename controllers, views, instances of the class, create new database migrations, and update the specs. Sound scary? It won't run any DB migrations, so you can set it, and then review the changes to make sure they're up to standard. Once you're happy with what's been changed you can run `rake db:migrate`, start the server, and check it all out.

## Installation

To install:

    `gem install rails_magic_renamer`

If you encounter an error installing the gem, as ruby-filemagic does not install, then follow the instructions in this Stack Overflow question to install it: http://stackoverflow.com/questions/15577171/missing-library-while-installing-ruby-filemagic-gem-on-linux

Before use, make sure you `cd` to the root of your rails project.

To rename an object open up `rails console` in your app's root folder and run:

    require 'rails_magic_renamer'
    RailsMagicRenamer::Renamer.new("FromModel", "ToModel").rename

It's important to pass in the camelized class names, rather than the underscored class names. `RailsMagicRenamer` will throw an exception if you pass in underscored class names

This will:

* Commit previously unchanged changes to git so it starts from a clean working directory
* Update relationships in model fields (has_many, belongs_to, has_many, through)
* Create database migrations to rename the model table
* Create database migrations to update foreign key fields in other tables
* Rename the model itself and the class
* Rename references to relationships (eg user.posts -> user.articles)
* Rename the controller file & class name in file
* Rename the controller spec file & class name in file
* Rename the view directory
* Rename the model's partials
* rename the helper file & module name in file
* Updates routes
* rename the spec file & class name in file

## Issues

If you encounter any issues, please lodge an issue using the Github Issues feature. In your issue please include your rails version, ruby version, and if possible a link to the application where the issue was encountered. And don't forget a detailed description of the issue encountered :)

# Contributing

We love your contributions to RailsMagicRenamer. Before submitting a pull request, please make sure that your changes are well tested.

Then, you'll need to install bundler and the gem dependencies:

  `gem install bundler && bundle install`

  You should now be able to run the tests locally:

    bundle exec rake

Interact with rails_magic_renamer by creating a RailsMagicRenamer instance, and then calling `rename` on that instance. (You'll need to require 'rails_magic_renamer' first)
  
    RailsMagicRenamer::Renamer.new("CurrentModelName", "NewModelName").rename

Any questions open an issue or hit me up on Twitter: [@nmdowse](https://twitter.com/nmdowse).
