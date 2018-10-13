module Semantic
  # A small Crystal utility class for storing, parsing, and comparing SemVer-style version strings.
  class Version

    include Comparable(Version)

    SEMVER_REGEXP = /\A(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-((?:0|[1-9]\d*|\d*[a-zA-Z-][a-zA-Z0-9-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][a-zA-Z0-9-]*))*))?(?:\+([0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*))?\Z/

    property major : Int32
    property minor : Int32
    property patch : Int32
    property pre : String?

    getter build : String?

    # Initialize a new `Semantic::Version` from a version string.
    #
    # The string must be a valid SemVer string, containing at least major, minor, and patch elements.
    # Pre and build elements are optional.
    #
    # Examples of valid strings:
    #
    # ```
    # "2.4.6"
    # "25.58.100"
    # "1.0.0-pre1"
    # "1.0.0+build.112358"
    # "2.0.5-alpha+prerelease"
    # ```
    def initialize(version_string : String)
      match = version_string.match(SEMVER_REGEXP)

      raise ArgumentError.new("Supplied version string is not a valid SemVer Version") if match.nil?
      @major = match[1].to_i
      @minor = match[2].to_i
      @patch = match[3].to_i
      @pre = match[4]?
      @build = match[5]?
    end

    # Initialize a new `Semantic::Version` from a hash.
    #
    # The hash must contain "major", "minor", and "patch" keys with values. "Pre" and "build" elements are
    # optional. The hash may contain other keys, too. Those are discarded on initialization.
    #
    # Example:
    #
    # ```
    # hash = {
    #   "major" => 2,
    #   "minor" => 4,
    #   "patch" => 0, 
    # }
    # version = Semantic::Version.new(hash)
    # ```
    def initialize(version : Hash(String, Int32 | String | Nil))
      raise ArgumentError.new("You didn't supply all necessary keys in your version hash") unless has_required_keys?(version)
      clean = version.select("major", "minor", "patch", "pre", "build")
      @major = clean["major"].to_i
      @minor = clean["minor"].to_i
      @patch = clean["patch"].to_i
      @pre = clean.has_key?("pre") ? clean["pre"].to_s : nil
      @build = clean.has_key?("build") ? clean["build"].to_s : nil
    end

    # Initialize a new `Semantic::Version` from a tuple `T(Int32, Int32, Int32)`.
    def initialize(version : { Int32, Int32, Int32 })
      @major = version[0]
      @minor = version[1]
      @patch = version[2]
      @pre, @build = nil, nil
    end

    # Initialize a new `Semantic::Version` from a tuple `T(Int32, Int32, Int32, String?, String?)`.
    def initialize(version : {Int32, Int32, Int32, String?, String?})
      @major = version[0]
      @minor = version[1]
      @patch = version[2]
      @pre = version[3]?
      @build = version[4]?
    end

    # Initialize a new `Semantic::Version` from a named tuple.
    #
    # Example:
    #
    # ```
    # tuple = {
    #   major: 2,
    #   minor: 4,
    #   patch: 0,
    #   pre: nil,
    #   build: "prerelease" 
    # }
    # Semantic::Version.new(tuple)
    # ```
    def initialize(version : NamedTuple(major: Int32, minor: Int32, patch: Int32, pre: String?, build: String?))
      @major = version[:major]
      @minor = version[:minor]
      @patch = version[:patch]
      @pre = version[:pre]
      @build = version[:build]
    end

    # Returns a version string.
    #
    # ```
    # Semantic::Version.new("2.4.0-pre1+build.1123").to_s   # => "2.4.0-pre1+build.1123"
    # ```
    def to_s
      String.build do |io|
        io << [@major, @minor, @patch].join(".")
        io << "-" << @pre unless @pre.nil?
        io << "+" << @build unless @build.nil?
      end
    end

    # Returns an array of the elements of the version.
    #
    # ```
    # Semantic::Version.new("2.4.0-pre1+build.1123").to_a   # => [2, 4, 0, "pre1", "build.1123"]
    # ```
    def to_a
      [@major, @minor, @patch, @pre, @build]
    end

    # Returns version information as a hash.
    #
    # ```
    # Semantic::Version.new("2.4.0-pre1+build.1123").to_h
    # # => {"major" => 2, "minor" => 4, "patch" => 0, "pre" => "pre1", "build" => "build.1123"}
    # ```
    def to_h
      {
        "major" => @major,
        "minor" => @minor,
        "patch" => @patch,
        "pre" => @pre,
        "build" => @build
      }
    end

    # Returns version information as a tuple.
    #
    # ```
    # Semantic::Version.new("2.4.0-pre1+build.1123").to_t
    # # => {major: 2, minor: 4, patch: 0, pre: "pre1", build: "build.1123"}
    # ```
    def to_t
      {
        major: @major,
        minor: @minor,
        patch: @patch,
        pre: @pre,
        build: @build
      }
    end

    # Convenience method for testing whether a version is greater than supplied version.
    def gt?(other : Version)
      self > other
    end

    # Convenience method for testing whether a version is greater than supplied version string.
    def gt?(other : String)
      gt?(Version.new(other))
    end

    # Convenience method for testing whether a version is greater or equal than supplied version.
    def gte?(other : Version)
      self >= other
    end

    # Convenience method for testing whether a version is greater or equal than supplied version string.
    def gte?(other : String)
      gte?(Version.new(other))
    end

    # Convenience method for testing whether a version is less than supplied version.
    def lt?(other : Version)
      self < other
    end

    # Convenience method for testing whether a version is less than supplied version string.
    def lt?(other : String)
      lt?(Version.new(other))
    end

    # Convenience method for testing whether a version is less or equal than supplied version.
    def lte?(other : Version)
      self <= other
    end

    # Convenience method for testing whether a version is less or equal than supplied version string.
    def lte?(other : String)
      lte?(Version.new(other))
    end

    # Convenience method for testing whether a version is equal to supplied version.
    def eql?(other : Version)
      self == other
    end

    # Convenience method for testing whether a version is equal to supplied version string.
    def eql?(other : String)
      eql?(Version.new(other))
    end

    # Queries whether a version string with a constraint operator is satisfied with the instance.
    #
    # Supported constraints are wildcard (*) and tilde (~) version ranges. Examples:
    #
    # ```
    # version = Semantic::Version.new("2.4.8")
    # version.satisfies?("2.*")       # => true, >= 2.0.0 and < 3.0.0
    # version.satisfies?("2.4.*")     # => true, >= 2.4.0 and < 2.5.0
    # version.satisfies?("~2.3")      # => true, >= 2.3.0 and < 3.0.0
    # version.satisfies?("~2.3.6")    # => false, >= 2.3.6 and < 2.4.0
    # ```
    def satisfies?(version : String)
      return true if version.strip == "*"
      elems = version.split(/(\d(.+)?)/, 2).map &.strip
      comparator, str = elems[0], elems[1]

      begin
        comparator = comparator.empty? ? "*" : comparator
        satisfies_comparator?(comparator, str)
      rescue exception : ArgumentError
        raise exception        
      end
    end

    # Bumps up major version number and returns a new `Semantic::Version` instance.
    #
    # Note: this will clear pre and build version information for the new instance.
    def major! : Version
      new_version = dup
      new_version.increment_major
      new_version
    end

    # Bumps up minor version number and returns a new `Semantic::Version` instance.
    #
    # Note: this will clear pre and build version information for the new instance.
    def minor! : Version
      new_version = dup
      new_version.increment_minor
      new_version
    end

    # :nodoc:
    def increment_major
      @major += 1
      @minor = 0
      @patch = 0
      reset_pre_build
    end

    # :nodoc:
    def increment_minor
      @minor += 1
      @patch = 0
      reset_pre_build
    end

    # :nodoc:
    def increment_patch
      @patch += 1
      reset_pre_build
    end
    
    # :nodoc:
    def <=>(other : Version)
      result = compare_version(other)
      result == 0 ? compare_pre(other) : result
    end

    # :nodoc:
    def <=>(other : Nil)
      1
    end

    # :nodoc:
    def <=>(version : String)
      self <=> Version.new(version)
    end

    # :nodoc:
    def >(other : Version)
      (self <=> other) == 1
    end

    # :nodoc:
    def >(other : Nil)
      !!(self <=> other)
    end

    # :nodoc:
    def <(other : Version)
      (self <=> other) == -1
    end

    # :nodoc:
    def <(other : Nil)
      !(self <=> nil)
    end

    # :nodoc:
    def <=(other : Version)
      [0, -1].includes?(self <=> other)
    end

    # :nodoc:
    def >=(other : Version)
      [0, 1].includes?(self <=> other)
    end

    private def satisfies_comparator?(comparator, str)
      case comparator
      when "~"
        tilde_matches?(str)
      when "~>"
        pessimistic_matches?(str)
      else
        wildcard_matches?(str)
      end
    end

    private def tilde_matches?(str)
      elems = str.split(".").map &.to_i
      scope = elems.size
      elems << 0 if scope == 2
      version = Version.new(elems.join("."))
      self >= version && self < ceiling_version(version, scope)
    end

    private def pessimistic_matches?(str)
      tilde_matches?(str)
    end

    private def wildcard_matches?(str)
      begin
        elems = str.split(".").reject{|e| e == "*"}.map &.to_i
        scope = elems.size + 1
        (3 - elems.size).times do
          elems << 0
        end
        floor = Version.new(elems.join("."))
        ceiling = ceiling_version(floor, scope)
        self >= floor && self < ceiling
      rescue exception : ArgumentError
        raise ArgumentError.new("Your version string isn't SemVer compatible.")
      end
    end

    private def ceiling_version(version : Version, scope : Int32) : Version
      return version.major! if scope == 2
      return version.minor! if scope == 3
      return version
    end

    private def reset_pre_build
      @pre = nil
      @build = nil
    end

    private def has_required_keys?(version)
      version.has_key?("major") &&
        version.has_key?("minor") &&
        version.has_key?("patch")
    end

    private def compare_version(other : Version)
      [
        compare_elem(self.major, other.major),
        compare_elem(self.minor, other.minor),
        compare_elem(self.patch, other.patch)
      ].each do |result|
        return result if result != 0
      end
      0
    end

    def compare_elem(one : Int32, other : Int32)
      one <=> other
    end

    private def compare_pre(other : Version)
      if self.pre.nil? || other.pre.nil?
        return pre_nil_comparison(other)
      else
        a, b = pre_identifiers(self.pre), pre_identifiers(other.pre)
        comparison = compare_pre_identifiers(a, b)
        return comparison unless comparison == 0
        return a.size <=> b.size
      end
    end

    private def compare_pre_identifiers(one, other)
      smallest = one.size < other.size ? one : other
      smallest.each_with_index do |e, i|
        value1, value2 = one[i], other[i]

        if value1 && value2
          comparison = value1 <=> value2
          return comparison unless comparison == 0
        else
          return value1.is_a?(Int32) ? -1 : 1
        end
      end
      return 0
    end

    private def pre_identifiers(elem : Nil)
      [] of (Int32 | Nil)
    end

    private def pre_identifiers(elem : String)
      result = Array(Int32 | Nil).new
      array = elem.split(/[\.\-]/)
      array.each do |e|
        value = /\A\d+\z/.match(e) ? Int32.new(e) : nil
        result << value
      end
      return result
    end

    private def pre_nil_comparison(other : Version)
      return 0 if self.pre.nil? && other.pre.nil?
      return 1 if self.pre.nil?
      return -1 if other.pre.nil?
    end
  end
end