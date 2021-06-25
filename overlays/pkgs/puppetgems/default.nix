{ lib, bundlerApp, bundlerUpdateScript }:

bundlerApp {
  pname = "puppet";
  gemdir = ./.;
  exes = [ "puppet" "puppet-lint"];

  passthru.updateScript = bundlerUpdateScript "";

}
