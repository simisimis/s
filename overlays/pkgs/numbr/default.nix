{
  lib,
  fetchFromGitHub,
  rustPlatform,
  makeWrapper,
  pkg-config,
  wayland,
  libxkbcommon,
  libGL,
}:

rustPlatform.buildRustPackage {
  pname = "numbr";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "alexjoedt";
    repo = "numbr";
    rev = "9660945f4574c54465f51fc0b8d029248ae14a18";
    hash = "sha256-anvBfINBj/Rfn5DIjlrYGhBDekbJmM7cYBjplKedOm0=";
  };

  cargoHash = "sha256-D4sF2UAdIzdUGD/TuBq6ZTLyi1moICUldoPBTuCbOJM=";

  nativeBuildInputs = [ makeWrapper pkg-config ];
  buildInputs = [ wayland libxkbcommon libGL ];

  postFixup = ''
    wrapProgram $out/bin/numbr \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ wayland libxkbcommon libGL ]}
  '';

  meta = with lib; {
    description = "Natural-language calculator for Linux/Wayland";
    homepage = "https://github.com/alexjoedt/numbr";
    license = with licenses; [ mit asl20 ];
    platforms = platforms.linux;
    mainProgram = "numbr";
  };
}
