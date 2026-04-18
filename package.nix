{
  lib,
  stdenvNoCC,
  fetchurl,
  dpkg,
  makeWrapper,
  autoPatchelfHook,
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  atk,
  cairo,
  cups,
  dbus,
  expat,
  fontconfig,
  freetype,
  gdk-pixbuf,
  glib,
  gtk3,
  libdrm,
  libGL,
  libxkbcommon,
  libxkbfile,
  mesa,
  nspr,
  nss,
  pango,
  pipewire,
  libx11,
  libxcb,
  libxcomposite,
  libxdamage,
  libxext,
  libxfixes,
  libxrandr,
  libxshmfence,
  libxtst,
  libsecret,
  libnotify,
  systemd,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "helium";
  version = "0.11.3.2";

  src = fetchurl {
    url = "https://github.com/imputnet/helium-linux/releases/download/${finalAttrs.version}/helium-bin_${finalAttrs.version}-1_amd64.deb";
    hash = "sha256-Dc9gtij5o7dGAnkE/asgIMo0d7HBp5fGTt+iLS2Ys0M=";
  };

  nativeBuildInputs = [
    dpkg
    makeWrapper
    autoPatchelfHook
  ];

  buildInputs = [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    atk
    cairo
    cups
    dbus
    expat
    fontconfig
    freetype
    gdk-pixbuf
    glib
    gtk3
    libdrm
    libGL
    libxkbcommon
    libxkbfile
    mesa
    nspr
    nss
    pango
    pipewire
    libsecret
    libnotify
    libx11
    libxcb
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxrandr
    libxshmfence
    libxtst
  ];

  runtimeDependencies = [
    (lib.getLib systemd)
  ];

  # Qt shims are only loaded under KDE/Plasma for native Qt file dialogs.
  # Under GTK desktops they are never dlopen'd, so we ignore them instead of
  # pulling Qt into buildInputs.
  autoPatchelfIgnoreMissingDeps = [
    "libQt5Core.so.5"
    "libQt5Gui.so.5"
    "libQt5Widgets.so.5"
    "libQt6Core.so.6"
    "libQt6Gui.so.6"
    "libQt6Widgets.so.6"
  ];

  dontConfigure = true;
  dontBuild = true;
  dontStrip = true;

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb -x $src .
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/opt/helium $out/bin $out/share

    cp -r opt/helium/. $out/opt/helium/
    cp -r usr/share/applications $out/share/
    cp -r usr/share/icons $out/share/
    cp -r usr/share/metainfo $out/share/ || true

    makeWrapper $out/opt/helium/helium-wrapper $out/bin/helium \
      --add-flags "--ozone-platform-hint=auto" \
      --add-flags "--enable-features=WaylandWindowDecorations,WebRTCPipeWireCapturer" \
      --add-flags "--enable-wayland-ime=true"

    substituteInPlace $out/share/applications/helium.desktop \
      --replace-fail "Exec=helium %U" "Exec=$out/bin/helium %U" \
      --replace-fail "Exec=helium --incognito" "Exec=$out/bin/helium --incognito" \
      --replace-fail "Exec=helium" "Exec=$out/bin/helium"

    runHook postInstall
  '';

  meta = {
    description = "Private, fast, and honest web browser (Chromium-based)";
    homepage = "https://helium.computer/";
    license = lib.licenses.gpl3Only;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    mainProgram = "helium";
  };
})
