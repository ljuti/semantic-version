module Semantic
  class Version
    include Comparable(Version)

    SEMVER_REGEXP = /\A(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-((?:0|[1-9]\d*|\d*[a-zA-Z-][a-zA-Z0-9-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][a-zA-Z0-9-]*))*))?(?:\+([0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*))?\Z/

    property major : Int32
    property minor : Int32
    property patch : Int32
    property pre : String?

    getter build : String?

    def initialize(version_string : String)
      match = version_string.match(SEMVER_REGEXP)

      raise ArgumentError.new("Supplied version string is not a valid SemVer Version") if match.nil?
      @major = match[1].to_i
      @minor = match[2].to_i
      @patch = match[3].to_i
      @pre = match[4]?
      @build = match[5]?
    end

    def initialize(version : Hash(String, Int32 | String | Nil))
      raise ArgumentError.new("You didn't supply all necessary keys in your version hash") unless has_required_keys?(version)
      clean = version.select("major", "minor", "patch", "pre", "build")
      @major = clean["major"].to_i
      @minor = clean["minor"].to_i
      @patch = clean["patch"].to_i
      @pre = clean.has_key?("pre") ? clean["pre"].to_s : nil
      @build = clean.has_key?("build") ? clean["build"].to_s : nil
    end

    def initialize(version : { Int32, Int32, Int32 })
      @major = version[0]
      @minor = version[1]
      @patch = version[2]
      @pre, @build = nil, nil
    end

    def initialize(version : {Int32, Int32, Int32, String?, String?})
      @major = version[0]
      @minor = version[1]
      @patch = version[2]
      @pre = version[3]?
      @build = version[4]?
    end

    def initialize(version : NamedTuple(major: Int32, minor: Int32, patch: Int32, pre: String?, build: String?))
      @major = version[:major]
      @minor = version[:minor]
      @patch = version[:patch]
      @pre = version[:pre]
      @build = version[:build]
    end

    def <=>(other : Version)
      result = compare_version(other)
      result == 0 ? compare_pre(other) : result
    end

    def <=>(other : Nil)
      1
    end

    private def compare_version(other : Version)
      {% for part in ["major", "minor", "patch"] %}
        self.{{part.id}} <=> other.{{part.id}}
      {% end %}
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

    def <=>(version : String)
      self <=> Version.new(version)
    end

    def to_s
      String.build do |io|
        io << [@major, @minor, @patch].join(".")
        io << "-" << @pre unless @pre.nil?
        io << "+" << @build unless @build.nil?
      end
    end

    def to_a
      [@major, @minor, @patch, @pre, @build]
    end

    def to_h
      {
        "major" => @major,
        "minor" => @minor,
        "patch" => @patch,
        "pre" => @pre,
        "build" => @build
      }
    end

    def to_t
      {
        major: @major,
        minor: @minor,
        patch: @patch,
        pre: @pre,
        build: @build
      }
    end

    def >(other : Version)
      (self <=> other) == 1
    end

    def >(other : Nil)
      !!(self <=> other)
    end

    def <(other : Version)
      (self <=> other) == -1
    end

    def <(other : Nil)
      !(self <=> nil)
    end

    def <=(other : Version)
      [0, -1].includes?(self <=> other)
    end

    def >=(other : Version)
      [0, 1].includes?(self <=> other)
    end

    private def has_required_keys?(version)
      version.has_key?("major") &&
        version.has_key?("minor") &&
        version.has_key?("patch")
    end
  end
end