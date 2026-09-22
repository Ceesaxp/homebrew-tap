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
      url "https://github.com/Ceesaxp/telegram-cli/releases/download/v0.0.28/telegram-cli_v0.0.28_darwin_arm64.tar.gz"
      sha256 "a020f6d89aa5954b65ab4d4edcb5f6bfd2f36245b5136efd1fcc46085c29ee0a"
    end
    on_intel do
      url "https://github.com/Ceesaxp/telegram-cli/releases/download/v0.0.28/telegram-cli_v0.0.28_darwin_amd64.tar.gz"
      sha256 "fe5d90442188081986560766383d1d55a72a71ccc056d95680671150b0a5132d"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/Ceesaxp/telegram-cli/releases/download/v0.0.28/telegram-cli_v0.0.28_linux_arm64.tar.gz"
      sha256 "b1cd37a3bd8497e17a9838cdf6406ad742fe527ef47ad1614a2a34c7dc1117c9"
    end
    on_intel do
      url "https://github.com/Ceesaxp/telegram-cli/releases/download/v0.0.28/telegram-cli_v0.0.28_linux_amd64.tar.gz"
      sha256 "21c07bb338693b60379a9018ce1e9e922eb9dba146a8cc1aad3275eeea562fc9"
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
