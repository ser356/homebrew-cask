# Instalación:
#   brew tap ser356/cask
#   brew install --cask alexandria
#
# Qué hace este cask:
#   1. Descarga el DMG con `Alexandria.app` (build sin firmar Developer ID —
#      solo firma ad-hoc que cargo tauri build genera).
#   2. Copia el .app a /Applications → aparece en Launchpad/Spotlight.
#   3. Crea un symlink `alexandria` en /opt/homebrew/bin apuntando al
#      binario dentro del bundle → mismo ejecutable dual (GUI si arranca
#      sin args, CLI con subcomandos).
#   4. Postflight limpia com.apple.quarantine → la app abre con doble click
#      sin el bloqueo de Gatekeeper típico de apps no notarizadas.
#   5. `brew uninstall --cask` + `--zap` borra config del user.
cask "alexandria" do
  version "0.4.4"
  sha256 "a0a8de9e2a6bdd4fb96f5a9c3f6b10c689658fa981edb19b62bdf72f47072641"

  url "https://github.com/ser356/alexandria-releases/releases/download/v#{version}/Alexandria_#{version}_aarch64.dmg"
  name "Alexandria"
  desc "Descubre y descarga ebooks desde fuentes abiertas"
  homepage "https://github.com/ser356/alexandria-releases"

  # arm64 only por ahora. Los Macs Intel con Rosetta 2 pueden ejecutar
  # el binario arm64 igualmente.
  depends_on macos: :catalina

  app "Alexandria.app"

  # Symlink del binario dentro del bundle → user puede correr:
  #   alexandria                 # sin args = GUI
  #   alexandria search "..."    # CLI
  binary "#{appdir}/Alexandria.app/Contents/MacOS/alexandria", target: "alexandria"

  # Limpia com.apple.quarantine automáticamente tras la instalación.
  # Sin esto, macOS Sequoia+ bloquea la app sin ofrecer siquiera el
  # botón "Abrir de todas formas" en Ajustes → Privacidad y seguridad
  # (solo aparece "Trasladar a la papelera"). La firma ad-hoc que
  # cargo tauri build genera es correcta — el bloqueo es puramente por
  # el flag de cuarentena que Gatekeeper añade al descargar el DMG.
  postflight do
    system_command "/usr/bin/xattr",
                   args: ["-cr", "#{appdir}/Alexandria.app"],
                   sudo: false
  end

  caveats <<~EOS
    Alexandria no está firmado con Developer ID de Apple (solo firma
    ad-hoc). El cask limpia com.apple.quarantine automáticamente en
    postinstall, así que la app debería abrir con doble click.

    Si por alguna razón sigue bloqueada, ejecuta manualmente:
      xattr -cr /Applications/Alexandria.app

    Uso desde terminal (mismo binario que la GUI):
      alexandria search "titulo"
      alexandria download <edition-id>
  EOS

  zap trash: [
    "~/Library/Application Support/dev.ser356.alexandria",
    "~/Library/Caches/dev.ser356.alexandria",
    "~/Library/Preferences/dev.ser356.alexandria.plist",
    "~/Library/WebKit/dev.ser356.alexandria",
  ]
end
