self: super: 
rec {
  puppetgems = super.callPackage ./pkgs/puppetgems { };
  pdk = super.callPackage ./pkgs/pdk { };
  wally-cli = super.callPackage ./pkgs/wally-cli { };
}
