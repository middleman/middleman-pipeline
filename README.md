# Middleman-Pipeline

`middleman-pipeline` is an extension for the [Middleman] static site generator that adds [Rake::Pipeline](https://github.com/livingsocial/rake-pipeline) support

## Installation

If you're just getting started, install the `middleman` gem and generate a new project:

```
gem install middleman
middleman init MY_PROJECT
```

If you already have a Middleman project: Add `gem "middleman-pipeline"` to your `Gemfile` and run `bundle install`.

## Configuration

```
activate :pipeline
```

## Build & Dependency Status

[![Gem Version](https://badge.fury.io/rb/middleman-pipeline.png)][gem]
[![Build Status](https://travis-ci.org/middleman/middleman-pipeline.png)][travis]
[![Dependency Status](https://gemnasium.com/middleman/middleman-pipeline.png?travis)][gemnasium]
[![Code Quality](https://codeclimate.com/github/middleman/middleman-pipeline.png)][codeclimate]

## Community

The official community forum is available at: http://forum.middlemanapp.com

## Bug Reports

Github Issues are used for managing bug reports and feature requests. If you run into issues, please search the issues and submit new problems: https://github.com/middleman/middleman-pipeline/issues

The best way to get quick responses to your issues and swift fixes to your bugs is to submit detailed bug reports, include test cases and respond to developer questions in a timely manner. Even better, if you know Ruby, you can submit [Pull Requests](https://help.github.com/articles/using-pull-requests) containing Cucumber Features which describe how your feature should work or exploit the bug you are submitting.

## How to Run Cucumber Tests

1. Checkout Repository: `git clone https://github.com/middleman/middleman-pipeline.git`
2. Install Bundler: `gem install bundler`
3. Run `bundle install` inside the project root to install the gem dependencies.
4. Run test cases: `bundle exec rake test`

## Donate

[Click here to lend your support to Middleman](https://spacebox.io/s/4dXbHBorC3)

## License

Copyright (c) 2012-2013 Thomas Reynolds. MIT Licensed, see [LICENSE] for details.

[middleman]: http://middlemanapp.com
[gem]: https://rubygems.org/gems/middleman-pipeline
[travis]: http://travis-ci.org/middleman/middleman-pipeline
[gemnasium]: https://gemnasium.com/middleman/middleman-pipeline
[codeclimate]: https://codeclimate.com/github/middleman/middleman-pipeline
[LICENSE]: https://github.com/middleman/middleman-pipeline/blob/master/LICENSE.md