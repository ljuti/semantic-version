# semantic-version

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
