self: super: 
rec {
  puppet = super.callPackage ./pkgs/puppet6 { };
  pdk = super.callPackage ./pkgs/pdk { };
  wally-cli = super.callPackage ./pkgs/wally-cli { };
}
