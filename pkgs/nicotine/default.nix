{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  makeWrapper,
  libGL,
  libxkbcommon,
  wayland,
  xorg,
  vulkan-loader,
  wmctrl,
}:

rustPlatform.buildRustPackage rec {
  pname = "nicotine";
  version = "0.4.3";

  src = fetchFromGitHub {
    owner = "isomerc";
    repo = "nicotine";
    rev = "v${version}";
    hash = "sha256-OjfXalFh4v1hU9j3rYID+OG8M4TOWeJIRfualMq0tPA=";
  };

  # Cargo.lock is committed upstream — reuse it instead of vendoring by hand.
  cargoLock = {
    lockFile = "${src}/Cargo.lock";
  };

  nativeBuildInputs = [
    pkg-config
    makeWrapper
  ];

  buildInputs = [
    libGL
    libxkbcommon
    wayland
    xorg.libX11
    xorg.libXcursor
    xorg.libXrandr
    xorg.libXi
    xorg.libxcb
  ];

  postInstall = ''
    ln -sf Nicotine $out/bin/nicotine
  '';

  postFixup = ''
    for bin in $out/bin/Nicotine; do
      wrapProgram "$bin" \
        --prefix LD_LIBRARY_PATH : "${
          lib.makeLibraryPath [
            libGL
            libxkbcommon
            wayland
            vulkan-loader
            xorg.libX11
            xorg.libXcursor
            xorg.libXrandr
            xorg.libXi
            xorg.libxcb
          ]
        }" \
        --prefix PATH : "${lib.makeBinPath [ wmctrl ]}"
    done
  '';

  doCheck = false;

  meta = {
    description = "High-performance EVE Online multiboxing tool for Linux (X11 and Wayland)";
    longDescription = ''
      Nicotine is a multiboxing and client management tool for EVE Online,
      inspired by EVE-O Preview. It runs as a daemon and provides instant
      client cycling via mouse buttons or keyboard, an always-on-top overlay,
      and auto-stacking of multiple EVE client windows. Supports X11,
      KDE Plasma (Wayland via XWayland), Sway, and Hyprland.

      Note: requires the running user to be in the `input` group to read
      mouse/keyboard events via evdev. The binary also pings upstream on
      launch for version checks and telemetry.
    '';
    homepage = "https://github.com/isomerc/nicotine";
    changelog = "https://github.com/isomerc/nicotine/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "nicotine";
  };
}
