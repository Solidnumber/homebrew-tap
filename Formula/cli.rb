# Solid# CLI — AI Business Infrastructure from the terminal.
#
# Homebrew formula. Pulls the published npm tarball, installs runtime
# deps into the keg's libexec, and exposes `solid` on PATH. Releases
# auto-bump via .github/workflows/auto-bump.yml in THIS repo (polls
# npm every 4h, self-commits version + sha256 — no secrets needed);
# solid-cli's homebrew-bump.yml is the optional instant fast path.
class Cli < Formula
  desc "AI business infrastructure from the terminal — CRM, payments, voice AI, agents"
  homepage "https://solidnumber.com/docs/cli"
  url "https://registry.npmjs.org/@solidnumber/cli/-/cli-2.11.15.tgz"
  sha256 "8470c2fff3c0c11009cb7da1477ec3e1371f035ca050554c3534c5699aae174b"
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
