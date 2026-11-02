cask "writ" do
  version "0.7.0"
  sha256 "384351d52f2994cf044aa3aeebb7d1e0befaa7cb21d7145a54fd261a1dbe065c"

  url "https://github.com/Ceesaxp/Writ.app/releases/download/v#{version}/Writ-#{version}.dmg"
  name "Writ"
  desc "Markdown editor for technical writing"
  homepage "https://ceesaxp.github.io/writ/"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on macos: :sonoma

  app "Writ.app"

  zap trash: [
    "~/Library/Caches/org.ceesaxp.Writ",
    "~/Library/HTTPStorages/org.ceesaxp.Writ",
    "~/Library/HTTPStorages/org.ceesaxp.Writ.binarycookies",
    "~/Library/Preferences/org.ceesaxp.Writ.plist",
    "~/Library/Saved Application State/org.ceesaxp.Writ.savedState",
    "~/Library/WebKit/org.ceesaxp.Writ",
  ]
end
