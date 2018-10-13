# semantic-version

[![Built with Crystal](https://img.shields.io/badge/built%20with-crystal-000000.svg?style=flat-square)](https://crystal-lang.org/)
[![Build status](https://img.shields.io/travis/ljuti/semantic-version/master.svg?style=flat-square)](https://travis-ci.org/ljuti/semantic-version)

A small Crystal utility class for storing, parsing, and comparing SemVer-style version strings.

This class is a port of [semantic](https://github.com/jlindsey/semantic) Ruby gem over to Crystal.

## Usage

This library exposes a single class - `Semantic::Version`. Instantiate it a SemVer version as a string, hash, tuple or named tuple, and you've got a version object with a few methods.

```crystal
require "semantic-version"

version = Semantic::Version.new("4.2.0")
version.major             # => 4
version.minor             # => 2
version.patch             # => 0

release = Semantic::Version.new("5.2.0")
release > version         # => true
version <=> release       # => -1

with_tuple  = Semantic::Version.new({4, 2, 0})
with_hash   = Semantic::Version.new({ "major" => 2, "minor" => 3, "patch" => 0 })
with_ntuple = Semantic::Version.new({ major: 2, minor: 5, patch: 0, pre: nil, build: "build.1123" })
```

You can also compare versions.

```crystal
v_new = Semantic::Version.new("4.2.0")
v_old = Semantic::Version.new("2.4.0")

v_new > v_old       # => true
v_old < v_new       # => true
v_new.gt?(v_old)    # => true
v_old.lt?(v_new)    # => true
```

Convenience methods include:

* `gt?` - greater than
* `gte?` - greater than or equal to
* `lt?` - less than
* `lte?` - less than or equal to
* `eql?`- equal to

These work with SemVer version strings, too.

Some version constraints are supported. Wildcard (*) and tilde (~) version range operators are currently supported.

```crystal
version = Version.new("4.2.0")

version.satisfies?("4.*")         # => true   (>= 4.0.0 && < 5.0.0)
version.satisfies?("4.1.*")       # => false  !(>= 4.1.0 && < 4.2.0)
version.satisfies?("4.2.*")       # => true   (>= 4.2.0 && < 4.3.0)

version.satisfies?("~ 4.1")       # => true   (>= 4.1.0 && < 5.0.0)
version.satisfies?("~ 4.1.5")     # => false  !(>= 4.1.5 && < 4.2.0)
```

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  semantic-version:
    github: ljuti/semantic-version
```

## Contributing

1. Fork it (<https://github.com/ljuti/semantic-version/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [ljuti](https://github.com/ljuti) Lauri Jutila - creator, maintainer
