require "./spec_helper"

Spec2.describe Semantic::Version do
  let(good_versions) do
    [
      "1.0.0",
      "42.69.888",
      "0.0.1-pre1",
      "3.8.6-pre.8+build.112358.0",
      "9.9.9+999",
      "4.2.0+tesla",
      "3.2.1-0"
    ]
  end

  let(bad_versions) do
    [
      "x.y.z",
      "9.to.5",
      "r.2.d.2",
      "x.8.6",
      "6.9.i",
      "alpha0-1.2.3",
      "Multi-line\n1.2.3\Version String"
    ]
  end

  describe "Initialization" do
    context "from a tuple" do
      it "is successful" do
        tuple = {
          major: 4,
          minor: 2,
          patch: 0,
          pre: "alpha8",
          build: "build.1123"
        }

        version = described_class.new(tuple)
        expect(version).to be_a(Semantic::Version)
        expect(version.major).to eq(4)
        expect(version.minor).to eq(2)
        expect(version.patch).to eq(0)
        expect(version.pre).to eq("alpha8")
        expect(version.build).to eq("build.1123")
      end

      it "is successful" do
        tuple = {4, 2, 0}

        version = described_class.new(tuple)
        expect(version).to be_a(Semantic::Version)
        expect(version.major).to eq(4)
        expect(version.minor).to eq(2)
        expect(version.patch).to eq(0)
      end

      it "is successful" do
        version = Semantic::Version.new({ major: 2, minor: 5, patch: 0, pre: nil, build: "build.1123" })
        expect(version).to be_a(Semantic::Version)
      end
    end

    context "from a hash" do
      context "with all required keys present" do
        let(only_required) do
          {
            "major" => 2,
            "minor" => 3,
            "patch" => 1,
            "pre" => "foo"
          }
        end

        let(without_pre) do
          {
            "major" => 4,
            "minor" => 2,
            "patch" => 0,
            "build" => "tesla"
          }
        end

        let(without_build) do
          {
            "major" => 0,
            "minor" => 26,
            "patch" => 1,
            "pre" => "1"
          }
        end

        let(with_extra_keys) do
          {
            "major" => 4,
            "minor" => 3,
            "patch" => 2,
            "foo" => "bar",
            "extra" => "keys"
          }
        end

        it "is successful" do
          expect(described_class.new(only_required)).to be_a(Semantic::Version)
          expect(described_class.new(without_pre)).to be_a(Semantic::Version)
          expect(described_class.new(without_build)).to be_a(Semantic::Version)
          expect(described_class.new(with_extra_keys)).to be_a(Semantic::Version)
        end
      end

      context "all keys present" do
        let(all_keys) do
          {
            "major" => 9,
            "minor" => 6,
            "patch" => 3,
            "pre" => "pre.1",
            "build" => "build.1123"
          }
        end

        it "is successful" do
          expect(described_class.new(all_keys)).to be_a(Semantic::Version)
        end
      end

      context "missing required keys" do
        let(missing) do
          {
            "major" => 1,
            "minor" => 2,
            "pre" => "missing",
            "build" => "keys"
          }
        end

        it "raises an error" do
          expect do
            described_class.new(missing)
          end.to raise_error(ArgumentError, match(/all necessary keys/))
        end
      end
    end
  end

  describe "Parsing" do
    context "valid SemVer versions" do
      it "is successful" do
        good_versions.each do |version|
          expect { described_class.new(version) }.not_to raise_error
        end
      end
    end

    context "invalid SemVer versions" do
      it "will fail" do
        bad_versions.each do |version|
          expect do
            described_class.new(version)
          end.to raise_error(ArgumentError, match(/not a valid SemVer Version/))
        end
      end
    end

    describe "member variables" do
      context "in regular SemVer" do
        subject { described_class.new("0.26.1") }

        it "are successfully parsed" do
          expect(subject.major).to eq(0)
          expect(subject.minor).to eq(26)
          expect(subject.patch).to eq(1)
          expect(subject.pre).to eq(nil)
          expect(subject.build).to eq(nil)
        end
      end

      context "in Semver with pre member" do
        subject { described_class.new("0.26.1-pre1") }

        it "are successfully parsed" do
          expect(subject.major).to eq(0)
          expect(subject.minor).to eq(26)
          expect(subject.patch).to eq(1)
          expect(subject.pre).to eq("pre1")
          expect(subject.build).to eq(nil)
        end
      end

      context "in Semver with build member" do
        subject { described_class.new("0.26.1-alpha8+zerozeroseven") }

        it "are successfully parsed" do
          expect(subject.major).to eq(0)
          expect(subject.minor).to eq(26)
          expect(subject.patch).to eq(1)
          expect(subject.pre).to eq("alpha8")
          expect(subject.build).to eq("zerozeroseven")
        end
      end
    end
  end

  describe "Comparing" do
    let(crystal_0261) { described_class.new("0.26.1-1") }
    let(crystal_0261_build1) { described_class.new("0.26.1-1+build.1123") }
    let(crystal_0261_build2) { described_class.new("0.26.1-1+build.2246") }
    let(crystal_0261_final) { described_class.new("0.26.1") }

    let(crystal_0260) { described_class.new("0.26.0") }
    let(crystal_0262) { described_class.new("0.26.2") }

    it "determines sort order" do
      expect(crystal_0261 <=> crystal_0261.to_s).to eq(0)

      expect(crystal_0261 <=> crystal_0261_build1).to eq(0)
      expect(crystal_0261 <=> crystal_0261_final).to eq(-1)
      expect(crystal_0261_build1 <=> crystal_0261_final).to eq(-1)

      expect(crystal_0260 <=> crystal_0261).to eq(-1)
      expect(crystal_0261 <=> crystal_0260).to eq(1)
      expect(crystal_0261 <=> crystal_0262).to eq(-1)
      expect(crystal_0262 <=> crystal_0261).to eq(1)

      versions = [crystal_0260, crystal_0261_build1, crystal_0261_final, crystal_0262]
      expect(versions.shuffle.sort).to eq([crystal_0260, crystal_0261_build1, crystal_0261_final, crystal_0262])
    end

    it "determines whether one is greater than another" do
      expect(crystal_0261 > crystal_0260).to be_true
      expect(crystal_0261_final > crystal_0261).to be_true

      expect(crystal_0261 > crystal_0262).not_to be_true
      expect(crystal_0261_build1 > crystal_0261_build2).not_to be_true
    end

    it "determines whether one is less than another" do
      expect(crystal_0261 < crystal_0260).not_to be_true
      expect(crystal_0261_final < crystal_0261).not_to be_true

      expect(crystal_0261 < crystal_0261_final).to be_true
      expect(crystal_0261 < crystal_0262).to be_true
      expect(crystal_0261_build1 < crystal_0261_build2).not_to be_true
    end

    it "determines whether one is greater or equal than another" do

    end

    it "determines whether one is less or equal than another" do

    end

    it "determines whether one is semantically equal to another" do
      expect(crystal_0261).to eq(crystal_0261.dup)
      expect(crystal_0261_build1).to eq(crystal_0261_build1.dup)

      expect(crystal_0261_build1).to eq(crystal_0261_build2)
      expect(crystal_0261_build1).to eq(crystal_0261)
    end

    it "determines whether one is between two other versions" do
      expect(crystal_0260 < crystal_0261 < crystal_0262).to be_true
    end

    context "Special cases" do
      subject { described_class.new("1.2.3") }

      it "can compare against nil" do
        expect(subject > nil).to be_true
        expect(subject == nil).to be_false
        expect(subject < nil).to be_false
      end
    end

    context "Satisfying specifications" do
      subject { described_class.new("2.4.8") }

      context "with wildcard operator" do
        it "matches all versions" { expect(subject.satisfies?("*")).to be_true }
        it "matches with matching major version" { expect(subject.satisfies?("2.*")).to be_true }
        it "matches with matching minor version" { expect(subject.satisfies?("2.4.*")).to be_true }
        it "doesn't match with matching major but greater minor" { expect(subject.satisfies?("2.5.*")).to be_false }
        it "doesn't match with greater major" { expect(subject.satisfies?("3.*")).to be_false }
        it "fails with non-conforming input" do
          expect do
            subject.satisfies?("2*")
          end.to raise_error(ArgumentError, "Your version string isn't SemVer compatible.")
        end
      end

      context "with tilde operator" do
        it "matches with expected major and minor versions" do
          expect(subject.satisfies?("~ 2.4")).to be_true
        end

        it "matches with expected major, minor, and patch version" do
          expect(subject.satisfies?("~ 2.4.8")).to be_true
        end

        it "doesn't match with expected major but greater minor version" do
          expect(subject.satisfies?("~ 2.5")).to be_false
        end

        it "doesn't match with expected major and minor, but greater patch version" do
          expect(subject.satisfies?("~ 2.4.9")).to be_false
        end

        it "doesn't match when its major version is too great" do
          expect(subject.satisfies?("~ 1.0")).to be_false
        end

        it "doesn't match when its minor version is too great" do
          expect(subject.satisfies?("~ 2.1.0")).to be_false
        end
      end
    end
  end

  describe "Type coercions" do
    let(version) { described_class.new("0.26.1-pre5+build.1123") }
    let(first) { described_class.new("1.0.0") }
    let(tesla) { described_class.new("4.2.0+dollars") }
    let(alpha) { described_class.new("0.0.7-alpha8") }

    describe "#to_s" do
      subject { version.to_s }

      it "converts to string" do
        expect(subject).to eq("0.26.1-pre5+build.1123")
      end
    end

    describe "#to_a" do
      subject { version.to_a }
      
      it "converts to an array" do
        expect(subject).to eq([0, 26, 1, "pre5", "build.1123"])
        expect(first.to_a).to eq([1, 0, 0, nil, nil])
        expect(tesla.to_a).to eq([4, 2, 0, nil, "dollars"])
        expect(alpha.to_a).to eq([0, 0, 7, "alpha8", nil])
      end
    end

    describe "#to_h" do
      subject { version.to_h }

      it "converts to a hash" do
        expect(subject).to eq({ "major" => 0, "minor" => 26, "patch" => 1, "pre" => "pre5", "build" => "build.1123" })
        expect(first.to_h).to eq({ "major" => 1, "minor" => 0, "patch" => 0, "pre" => nil, "build" => nil})
        expect(tesla.to_h).to eq({ "major" => 4, "minor" => 2, "patch" => 0, "pre" => nil, "build" => "dollars"})
        expect(alpha.to_h).to eq({ "major" => 0, "minor" => 0, "patch" => 7, "pre" => "alpha8", "build" => nil})
      end
    end

    describe "#to_t" do
      subject { version.to_t }

      it "converts to a tuple" do
        expect(subject).to eq({ major: 0, minor: 26, patch: 1, pre: "pre5", build: "build.1123" })
        expect(first.to_t).to eq({ major: 1, minor: 0, patch: 0, pre: nil, build: nil })
        expect(tesla.to_t).to eq({ major: 4, minor: 2, patch: 0, pre: nil, build: "dollars" })
        expect(alpha.to_t).to eq({ major: 0, minor: 0, patch: 7, pre: "alpha8", build: nil })
      end
    end
  end

  describe "Convenience methods" do
    let(version1) { described_class.new("1.0.0") }
    let(version2) { described_class.new("0.0.2") }
    let(version3) { described_class.new("1.0.0") }

    describe "#gt?" do
      it "returns true if version is greater than supplied" do
        expect(version1.gt?(version2)).to be_true
        expect(version2.gt?(version1)).to be_false
        expect(version1.gt?("0.9.1")).to be_true
        expect(version1.gt?("1.0.1")).to be_false
      end
    end

    describe "#lt?" do
      it "returns true if version is less than supplied" do
        expect(version1.lt?(version2)).to be_false
        expect(version2.lt?(version1)).to be_true
        expect(version1.lt?("2.0.0")).to be_true
        expect(version1.lt?("0.26.1")).to be_false
      end
    end

    describe "#gte?" do
      it "returns true if version is greater or equal than supplied" do
        expect(version1.gte?(version3)).to be_true
        expect(version2.gte?(version1)).to be_false
        expect(version1.gte?("1.0.0")).to be_true
        expect(version1.gte?("0.26.1")).to be_true
        expect(version1.gte?("2.0.0")).to be_false
      end
    end

    describe "#lte?" do
      it "returns true if version is less or equal than supplied" do
        expect(version1.lte?(version3)).to be_true
        expect(version1.lte?(version2)).to be_false
        expect(version1.lte?("1.0.0")).to be_true
        expect(version1.lte?("2.0.0")).to be_true
        expect(version1.lte?("0.26.1")).to be_false
      end
    end

    describe "#eql?" do
      it "returns true if version is equal to supplied" do
        expect(version1.eql?(version3)).to be_true
        expect(version1.eql?(version2)).to be_false
        expect(version1.eql?("1.0.0")).to be_true
      end
    end
  end
end
