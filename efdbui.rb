# Homebrew Formula for EFDBUI
# Usage: brew install --cask efdbui
#
# To create a tap:
# 1. Create a GitHub repository named homebrew-tap
# 2. Place this file in the repository as Casks/efdbui.rb
# 3. Users can install with: brew install yourusername/tap/efdbui

cask "efdbui" do
  version "1.0.0"
  sha256 :no_check  # Replace with actual SHA256 for production

  url "https://github.com/YOURUSERNAME/EFDBUI/releases/download/v#{version}/EFDBUI-#{version}.tar.gz"
  name "EFDBUI"
  desc "Object information viewer with multi-panel interface"
  homepage "https://github.com/YOURUSERNAME/EFDBUI"

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

