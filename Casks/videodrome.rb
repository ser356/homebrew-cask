# Homebrew Cask template — el workflow de release sustituye
# 0.2.0, v0.2.0, 5d387fe5f13111c05c8269b67755f454b78d00fd67b7e0b037d27641dbe24eb7 y ser356/letterboxd-cli y publica el fichero final
# en `ser356/homebrew-cask/Casks/videodrome.rb`.
#
# Instalación:
#   brew tap ser356/cask
#   brew install --cask videodrome
#
# Qué hace este cask:
#   1. Descarga el zip con `Videodrome.app` (build sin firmar).
#   2. Copia el .app a /Applications → aparece en Launchpad/Spotlight.
#   3. Crea un symlink `videodrome` en /opt/homebrew/bin apuntando al
#      binario dentro del bundle → mismo ejecutable dual (GUI si arranca
#      sin args, CLI/TUI con subcomandos).
#   4. Al hacer `brew uninstall --cask` limpia el .app, el symlink y los
#      datos de config del user (`~/Library/Application Support/videodrome`,
#      caches, credenciales del Keychain no se tocan — se limpian con
#      `videodrome keychain clear`).
cask "videodrome" do
  version "0.2.0"
  sha256 "5d387fe5f13111c05c8269b67755f454b78d00fd67b7e0b037d27641dbe24eb7"

  url "https://github.com/ser356/letterboxd-cli/releases/download/v0.2.0/videodrome-v0.2.0-macos-arm64.zip"
  name "Videodrome"
  desc "Recomendaciones Letterboxd + streaming BitTorrent en VLC"
  homepage "https://github.com/ser356/letterboxd-cli"

  # arm64 only — los runners macos-13 Intel de Actions están deprecated.
  # Los Macs Intel con Rosetta 2 pueden ejecutar el binario arm64.
  depends_on macos: ">= :catalina"
  depends_on cask: "vlc"

  app "Videodrome.app"

  # Symlink del binario dentro del bundle → user puede correr:
  #   videodrome                 # sin args = GUI
  #   videodrome recommend       # CLI
  #   videodrome torrents "..."  # CLI
  #   videodrome tui             # TUI en terminal
  binary "#{appdir}/Videodrome.app/Contents/MacOS/videodrome", target: "videodrome"

  caveats <<~EOS
    Videodrome no está firmado por Apple. La primera vez que lo abras
    macOS lo bloqueará. Para desbloquearlo:

      xattr -cr /Applications/Videodrome.app

    O bien: Ajustes del Sistema → Privacidad y seguridad → "Abrir de
    todas formas" tras el primer intento.

    Uso desde terminal (mismo binario que la GUI):
      videodrome recommend
      videodrome tui
      videodrome torrents "Alien" --year 1979

    Requiere sesión Letterboxd la primera vez (login desde la GUI o
    variables de entorno).
  EOS

  zap trash: [
    "~/Library/Application Support/videodrome",
    "~/Library/Caches/dev.ser356.videodrome",
    "~/Library/Preferences/dev.ser356.videodrome.plist",
    "~/Library/WebKit/dev.ser356.videodrome",
  ]
end
