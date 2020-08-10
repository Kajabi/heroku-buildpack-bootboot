🚨 **This buildpack is currently alpha software and relies on an unsupported fork of heroku-buildpack-ruby** 🚨

# Heroku Buildpack for Bootboot
This is a [Heroku Buildpack](http://devcenter.heroku.com/articles/buildpacks) for Ruby, Rack, and Rails apps, adding [bootboot](https://github.com/Shopify/bootboot) support on top of the [official Ruby buildpack](https://github.com/heroku/heroku-buildpack-ruby).

This buildpack assumes that you have the Kajabi Ruby buildpack run prior to this buildpack.

## Usage

### Ruby

Example Usage:

    $ ls
    Gemfile Gemfile.lock Gemfile_next.lock

    $ heroku create --buildpack https://github.com/Kajabi/heroku-buildpack-ruby.git
    $ heroku buildpacks:add https://github.com/Kajabi/heroku-buildpack-bootboot.git

    $ git push heroku master
    ...
    -----> Ruby app detected
    -----> Installing dependencies using Bundler version 1.17.3
           Running: bundle install --without development:test --path vendor/bundle --binstubs vendor/bundle/bin -j4 --deployment
           Fetching gem metadata from http://rubygems.org/..
           Installing rack (1.3.5)
           Using bundler (1.17.3)
           Your bundle is complete! It was installed into ./vendor/bundle
           Cleaning up the bundler cache.
    -----> Bootboot 👢👢 app detected
    -----> Dectected Bootboot environment variable DEPENDENCIES_NEXT
    -----> Using Gemfile and Gemfile_next.lock for Bundler
    -----> Installing bundler 2.0.2
    -----> Removing BUNDLED WITH version in the Gemfile_next.lock
    -----> Compiling Bootboot 👢👢
    -----> Using Ruby version: ruby-2.4.9
    -----> Installing dependencies using bundler 2.0.2
           Running: bundle install --without development:test --path vendor/bundle --binstubs vendor/bundle/bin_next -j4 --deployment
           Fetching gem metadata from https://rubygems.org/
           Resolving dependencies...
           Installing rack (2.0.8)
           Using bundler (2.0.2)
           Your bundle is complete! It was installed into ./vendor/bundle
           Cleaning up the bundler cache.
    -----> Discovering process types
           Procfile declares types -> (none)
           Default types for Ruby  -> console, rake

The buildpack will detect your app as Ruby if it has a `Gemfile_next.lock` file in the root directory. It will then proceed to run `bundle install` after setting up the appropriate environment for [ruby](http://ruby-lang.org) and [Bundler](https://bundler.io).

#### Bundler

For non-windows `Gemfile_next.lock` files, the `--deployment` flag will be used. In the case of windows, the `Gemfile_next.lock` will be deleted and Bundler will do a full resolve so native gems are handled properly. The `vendor/bundle` directory is cached between builds to allow for faster `bundle install` times. `bundle clean` is used to ensure no stale gems are stored between builds.

### Testing

The tests on this buildpack are written in Rspec to allow the use of `focused: true`. Parallelization of testing is provided by https://github.com/grosser/parallel_tests this lib spins up an arbitrary number of processes and running a different test file in each process, it does not parallelize tests within a test file. To run the tests: clone the repo, then `bundle install` then clone the test fixtures by running:

```sh
$ bundle exec hatchet install
```

then go to [hatchet](https://github.com/heroku/hatchet) repo and follow the
instructions to set it up.

Now run the tests:

```sh
$ bundle exec parallel_rspec -n 6 spec/
```

If you don't want to run them in parallel you can still:

```sh
$ bundle exec rake spec
```

Now go take a nap or do something for a really long time.
