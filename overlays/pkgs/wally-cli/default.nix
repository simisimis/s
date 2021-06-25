{ pkgs, lib, ... }:

pkgs.buildGoPackage {
  name = "wally-cli";
  goPackagePath = "github.com/zsa/wally-cli";

  src = pkgs.fetchFromGitHub {
    owner = "zsa";
    repo = "wally-cli";
    rev = "5fc17632dc04335107cdac51230cdd5e2aa05ea0";
    sha256 = "13yhs9bnzwp1xcdpnc8klq2ql3m8f3nrq3pmyy06fk0452r3vkk1";
  };

  nativeBuildInputs = with pkgs; [ pkg-config ];
  buildInputs = with pkgs; [ libusb ];
  goDeps = ./deps.nix;

  meta = with lib; {
    description = "Upload Ergodox keyboard ROM's";
    license = licenses.mit;
    homepage = https://github.com/zsa/wally;
  };
}
