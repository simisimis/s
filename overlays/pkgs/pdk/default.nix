{ lib, bundlerApp, bundlerUpdateScript }:

bundlerApp {
  pname = "pdk";
  gemdir = ./.;
  exes = [ "pdk" ];

  passthru.updateScript = bundlerUpdateScript "";

}
