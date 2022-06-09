{
  usr.pwdHash = "$6$KIkEj/repkZ$VbCapIcC2fAp1bjHn2hAbc/UbNj1T6mXZQkclf02VDSOqgl0YHdkEY.oj5g67UItaB5UYkYAPfeKSbo3LiFBR0";
  usr.ssh.gitea.identityFile = "~/.ssh/id_rsa_siMONSTER_gitea";
  usr.ssh.backute.identityFile = "~/.ssh/id_rsa_siMONSTER_backute";
  hw.hostName = "siMONSTER";
  hw.hostId = "f1b2a3d4";
  gitRepos.binfiles.ref = builtins.readFile /run/agenix/secret1;
  gitRepos.binfiles.rev = "a060ba98b9e06c2f28adf8d4d35f04f693188735";
  services.syncthing.dataDir = "Documents/papyrus";
  services.syncthing.configDir = ".config/syncthing";
}
