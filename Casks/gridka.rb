cask "gridka" do
  version "1.3.0"
  sha256 "31ccd1bf70b26fe1822c3c52d83601d61e0072c5de3076fd63490286c3b7d83a"

  url "https://github.com/Ceesaxp/gridka/releases/download/v#{version}/Gridka-#{version}.dmg",
      verified: "github.com/Ceesaxp/gridka/"
  name "Gridka"
  desc "Native macOS CSV viewer for very large files"
  homepage "https://github.com/Ceesaxp/gridka"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on macos: ">= :sonoma"

  app "Gridka.app"

  zap trash: [
    "~/Library/Caches/com.gridka.app",
    "~/Library/Application Support/com.gridka.app",
    "~/Library/Preferences/org.ceesaxp.gridka.app.plist",
    "~/Library/Saved Application State/org.ceesaxp.gridka.app.savedState",
  ]
end
