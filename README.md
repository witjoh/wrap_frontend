Stripped module to demonstrate some weird behaviour when passing an  array of hashes, with only one hash
===

This is a simple wrapper around the apache::vhost defined resource.

The problem we tried to solve here :

This wrap_frontend::vhost defined resources should be defined by the backend application needing a frontend vhost definition.
It is possible that the backend application is installed on multiple nodes.  The frontends will collect those exported wrap_frontend::vhost resources.

To avoid duplicated resources of the 'apache::vhost' definitions, we use the ensure_resource function.

Everything works fine unless we define an attribute that requires an array of hashes, with only one hash.

Somewhere on the way, those hashes are converted to an array of arrays.

This is what we get when running rspec tests :

````
  expected that the catalogue would contain Apache::Vhost[custom_vhost_param] with access_logs set to [{"file"=>"custom.log", "format"=>"common"}] but it is set to [["file", "custom.log"], ["format", "common"]]
````

Still looking how to solve this issue.

The environment
====

* puppet version 3.8.7
* ruby 2.1.9p490

Note about the rspec file
===
I used this module to play a bit with rspec 'shared_examples'.  Main goal of this exercise is looking for some ways
to make puppet-rspec more maintainable and more attractive avoiding a lot of repetition. (DRY)



Running the rspec
===

````
bundle install --without development system_tests
bundle exec rake spec
````

