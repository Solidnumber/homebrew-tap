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

  # solid-cli requires Node 20+. brew installs it as a dep if missing.
  depends_on "node@20"

  def install
    # Install runtime deps (omit dev) into the buildpath, then move
    # the whole package + a binstub into Homebrew's libexec so we
    # don't pollute the user's global npm prefix.
    system "npm", "install", *Language::Node.std_npm_install_args(libexec)

    # Wire `solid` into Homebrew's bin/. The binstub forwards to the
    # real entry under libexec/lib/node_modules/@solidnumber/cli/dist/index.js.
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  test do
    # If the binary is broken, this fails the formula. `--version`
    # is the cheapest possible boot smoke and prints the version
    # we just installed.
    assert_match version.to_s, shell_output("#{bin}/solid --version")
  end
end
