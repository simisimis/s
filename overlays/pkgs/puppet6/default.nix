{ lib, bundlerApp, bundlerUpdateScript }:

bundlerApp {
  pname = "puppet";
  gemdir = ./.;
  exes = [ "puppet" "puppet-lint" "hiera" "facter" "rspec" "rake" ];

  passthru.updateScript = bundlerUpdateScript "";

}
