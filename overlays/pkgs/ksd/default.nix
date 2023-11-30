{ pkgs, lib, ... }:

pkgs.buildGoModule {
  name = "ksd";
  version = "1.0.7";

  src = pkgs.fetchFromGitHub {
    owner = "mfuentesg";
    repo = "ksd";
    rev = "v1.0.7";
    sha256 = "sha256-I1UgZgVO55xBZnW3gN5QmNYKhWj8l40Hv8qitHAEZxk=";
  };

  vendorHash = "sha256-JB+otB8Sye/81NCfqJefWoGpHC611Veh7eszaCR2mpY=";

  meta = with lib; {
    description = "Kubernetes secret decoder a.k.a ksd";
    license = licenses.mit;
    homepage = https://github.com/mfuentesg/ksd;
  };
}
