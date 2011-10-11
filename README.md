# Porthos

A content mangement system under development by [Oktavilla](http://oktavilla.se) named after [Porthos](http://en.wikipedia.org/wiki/Jonathan_Archer#Porthos). It uses [Ruby 1.9.2](http://www.ruby-lang.org/en/), [Rails 3.1](http://rubyonrails.org/) and [MongoDB](http://www.mongodb.org/) to make the magic happen. It's packaged as a rails engine available as a [gem](http://rubygems.org/gems/porthos).

## Current status

The code available for Porthos on [github](https://github.com/Oktavilla/Porthos-Engine) is currently in production use on a few websites. However it is currently dependent of external services for handling assets and searching, our plan is to modularize these dependencies and add support for different storage solutions etc. There is also localization to finish, there is currently a lot of swedish in the project.

## Goal

The goal with porthos is to create a stable, powerfull and easy to use CMS for Rails. It should be easy to get started using Porthos but it should also allow for customization and integration into existing projects.

* Full test converage
* Localized interface
* Heroku ready
* Super-fast rendering of content
* Customization by using ”engines” for
  * assets storage
  * image resizing
  * document indexing
  * authentication


## Installation instructions

Add porthos to your Gemfile:

    gem 'porthos'

Run porthos generater:

    $ rails g porthos

...

## Contribute

* Check out the code and try to use it, add [issues](https://github.com/Oktavilla/Porthos-Engine/issues) for the problems and errors you find. 
* Fork and do a pull request if you want to fix something or add a feature. Please add tests.  
* Write [documentation](https://github.com/Oktavilla/Porthos-Engine/wiki).

