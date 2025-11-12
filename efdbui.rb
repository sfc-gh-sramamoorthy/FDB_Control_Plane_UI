# Homebrew Formula for EFDBUI
# Usage: brew install --cask efdbui
#
# To create a tap:
# 1. Create a GitHub repository named homebrew-tap
# 2. Place this file in the repository as Casks/efdbui.rb
# 3. Users can install with: brew install sfc-gh-sramamoorthy/tap/efdbui

cask "efdbui" do
  version "1.0.1"
  sha256 "393ced488c32f8d4c3cebf8a14107670ecc0062dc9727222a9e560d422911cde"

  url "https://github.com/sfc-gh-sramamoorthy/FDB_Control_Plane_UI/releases/download/v#{version}/EFDBUI-#{version}.tar.gz"
  name "EFDBUI"
  desc "FoundationDB Control Plane UI - Multi-panel interface for cluster management"
  homepage "https://github.com/sfc-gh-sramamoorthy/FDB_Control_Plane_UI"

  # Minimum macOS version
  depends_on macos: ">= :ventura"

  app "EFDBUI.app"

  # Optional: Create a CLI symlink
  binary "#{appdir}/EFDBUI.app/Contents/MacOS/EFDBUI", target: "efdbui"

  zap trash: [
    "~/Library/Preferences/com.efdb.ui.plist",
    "~/Library/Saved Application State/com.efdb.ui.savedState",
  ]
end

