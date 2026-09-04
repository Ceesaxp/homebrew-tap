class TeleTui < Formula
  desc "Keyboard-first Telegram client for the terminal, with MCP and REST front ends"
  homepage "https://github.com/Ceesaxp/telegram-cli"
  license "MIT"

  livecheck do
    url :stable
    strategy :github_latest
  end

  # Pre-built binaries rather than a source build. The project already
  # cross-compiles and publishes these from one `make dist` recipe, with a
  # checksums.txt written over the whole set — so the thing a user installs
  # is the thing the release was tested as, and `brew install` does not
  # spend minutes pulling the gotd module graph to arrive at the same bytes.
  #
  # They are CGO_ENABLED=0 static builds, which is why nothing is depended on
  # below: no Go toolchain at install time, and no libc to match on Linux.
  on_macos do
    on_arm do
      url "https://github.com/Ceesaxp/telegram-cli/releases/download/v0.0.18/telegram-cli_v0.0.18_darwin_arm64.tar.gz"
      sha256 "c71317fc3786a7dbaf7d36ce57bb8519d2e2fc626f9d808c0318fdd9a8f86458"
    end
    on_intel do
      url "https://github.com/Ceesaxp/telegram-cli/releases/download/v0.0.18/telegram-cli_v0.0.18_darwin_amd64.tar.gz"
      sha256 "26a4d9f0c189bd3afe674d2d1397ba763d0515d493b9db23259769d28f1c5f01"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/Ceesaxp/telegram-cli/releases/download/v0.0.18/telegram-cli_v0.0.18_linux_arm64.tar.gz"
      sha256 "2d6bd341a258bcf2e6da2f34309303d9079dcdac95d099db6d717b17e9c69004"
    end
    on_intel do
      url "https://github.com/Ceesaxp/telegram-cli/releases/download/v0.0.18/telegram-cli_v0.0.18_linux_amd64.tar.gz"
      sha256 "2a4bb90dac4cef3204545021f4e5b0f9142e8859866ca48363871fd30a7ba389"
    end
  end

  def install
    # Three binaries over one Telegram layer: the TUI, an MCP server over
    # stdio, and a JSON REST API.
    bin.install "tele-tui", "telegram-mcp", "telegram-api"

    # The example config is the reference for every setting, so it goes
    # somewhere a user can find it rather than staying in the tarball.
    pkgshare.install "config.example.toml"
    doc.install "README.md", "docs"
  end

  def caveats
    <<~EOS
      tele-tui talks to Telegram as your own account, not through a bot, so it
      needs your own API credentials. Create an application at

        https://my.telegram.org/apps

      and put the api_id / api_hash it gives you in

        ~/.config/tele-tui/config.toml

      Starting a copy of the example config:

        mkdir -p ~/.config/tele-tui
        cp #{opt_pkgshare}/config.example.toml ~/.config/tele-tui/config.toml

      Then run `tele-tui` and it will walk you through the login.

      telegram-mcp and telegram-api serve the same account to other programs.
      Both keep their own session, and telegram-api binds to loopback with a
      generated bearer token. Before pointing either at an agent, read which
      directories send_file is allowed to read from:

        #{opt_share}/doc/tele-tui/docs/configuration.md
    EOS
  end

  test do
    # Version, not behaviour: everything else needs an authorised session,
    # and a formula test must not require someone's Telegram account.
    assert_match "tele-tui v#{version}", shell_output("#{bin}/tele-tui --version")
    assert_match "telegram-mcp v#{version}", shell_output("#{bin}/telegram-mcp --version")
    assert_match "telegram-api v#{version}", shell_output("#{bin}/telegram-api --version")

    # The MCP server must fail loudly without credentials rather than hang
    # waiting on stdin for a protocol handshake it cannot answer.
    output = shell_output("#{bin}/telegram-mcp serve 2>&1", 1)
    assert_match(/credentials|config/i, output)
  end
end
