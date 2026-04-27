# Solid# CLI — AI Business Infrastructure from the terminal.
#
# Homebrew formula. Pulls the published npm tarball, installs into
# Homebrew's Cellar, and exposes `solid` on PATH. Future releases:
# the CI in github.com/Adam-Camp-King/solid-cli auto-opens a PR here
# bumping the version + sha256 on every `npm publish`.
class Cli < Formula
  desc "AI business infrastructure from the terminal — CRM, payments, voice AI, agents"
  homepage "https://solidnumber.com/docs/cli"
  url "https://registry.npmjs.org/@solidnumber/cli/-/cli-2.2.0.tgz"
  sha256 "6182194e3f493ccd2e338484b216dc3d08819d2e9a41fab462b0de205b8b387c"
  license "BUSL-1.1"

  # solid-cli requires Node 20+. brew installs `node` (current LTS) as
  # a dep — we deliberately don't pin node@20 because it's deprecated
  # upstream and any modern node satisfies our engines requirement.
  depends_on "node"

  def install
    # Install the package's runtime deps into a private prefix under
    # libexec, then symlink the `solid` binstub into Homebrew's bin/.
    # `--production` skips devDependencies (they're not needed at
    # runtime and our prepublishOnly verifier proves it).
    system "npm", "install", "--global", "--prefix=#{libexec}",
           "--production", "--omit=dev", "."
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  test do
    # If the binary is broken, this fails the formula. `--version`
    # is the cheapest possible boot smoke and prints the version
    # we just installed.
    assert_match version.to_s, shell_output("#{bin}/solid --version")
  end
end
