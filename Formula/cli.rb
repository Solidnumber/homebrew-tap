# Solid# CLI — AI Business Infrastructure from the terminal.
#
# Homebrew formula. Pulls the published npm tarball, installs runtime
# deps into the keg's libexec, and exposes `solid` on PATH. Future
# releases auto-bump via solid-cli's CI: every `npm publish` opens a
# PR here updating version + sha256.
class Cli < Formula
  desc "AI business infrastructure from the terminal — CRM, payments, voice AI, agents"
  homepage "https://solidnumber.com/docs/cli"
  url "https://registry.npmjs.org/@solidnumber/cli/-/cli-2.2.0.tgz"
  sha256 "6182194e3f493ccd2e338484b216dc3d08819d2e9a41fab462b0de205b8b387c"
  license "BUSL-1.1"

  # solid-cli requires Node 20+. brew installs `node` (current LTS) as
  # a dep — we don't pin node@20 because it's deprecated upstream.
  depends_on "node"

  def install
    # 1. Copy the entire extracted tarball into libexec.
    libexec.install Dir["*"]

    # 2. Resolve runtime deps (axios, commander, lighthouse, etc.).
    #    --omit=dev because devDeps aren't needed at runtime —
    #    solid-cli's prepublishOnly already proves that.
    cd libexec do
      system "npm", "install", "--omit=dev"
    end

    # 3. Make the entry script executable (shebang is `#!/usr/bin/env node`,
    #    which finds the node we depend_on via PATH at runtime).
    chmod 0755, libexec/"dist/index.js"

    # 4. Symlink the brew bin into the entry. Users get `solid` on PATH.
    bin.install_symlink libexec/"dist/index.js" => "solid"
  end

  test do
    # Cheapest possible boot smoke. Fails the formula if the binary
    # is broken or version drifts from the URL we declared above.
    assert_match version.to_s, shell_output("#{bin}/solid --version")
  end
end
