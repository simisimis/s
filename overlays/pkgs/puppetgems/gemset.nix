{
  facter = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1aqkfybnmifajfm8a1sk7rigpyf3lssbd8dcjrj60g2gkjmarf7j";
      type = "gem";
    };
    version = "2.5.7";
  };
  fast_gettext = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0ci71w9jb979c379c7vzm88nc3k6lf68kbrsgw9nlx5g4hng0s78";
      type = "gem";
    };
    version = "1.1.2";
  };
  gettext = {
    dependencies = ["locale" "text"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0764vj7gacn0aypm2bf6m46dzjzwzrjlmbyx6qwwwzbmi94r40wr";
      type = "gem";
    };
    version = "3.2.9";
  };
  gettext-setup = {
    dependencies = ["fast_gettext" "gettext" "locale"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1vfnayz20xd8q0sz27816kvgia9z2dpj9fy7z15da239wmmnz7ga";
      type = "gem";
    };
    version = "0.34";
  };
  hiera = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0m7rxky6v9vjwl5pjm3jf3y9sm7y2l6ch7808js5ajd0fck1hyx7";
      type = "gem";
    };
    version = "3.6.0";
  };
  json_pure = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1vllrpm2hpsy5w1r7000mna2mhd7yfrmd8hi713lk0n9mv27bmam";
      type = "gem";
    };
    version = "1.8.6";
  };
  locale = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0997465kxvpxm92fiwc2b16l49mngk7b68g5k35ify0m3q0yxpdn";
      type = "gem";
    };
    version = "2.1.3";
  };
  puppet = {
    dependencies = ["facter" "gettext-setup" "hiera" "json_pure" "locale"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0j4mf2d8gc6wsqb7dja6sszihrgmb069phl5r2k2vsckk064rpf2";
      type = "gem";
    };
    version = "4.10.12";
  };
  puppet-lint = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1pwpjxxr3wz71yl7jhhaa93fsrr72kz25isjydfhsf1igc9mfj9k";
      type = "gem";
    };
    version = "2.4.2";
  };
  sync = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1z9qlq4icyiv3hz1znvsq1wz2ccqjb1zwd6gkvnwg6n50z65d0v6";
      type = "gem";
    };
    version = "0.5.0";
  };
  text = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1x6kkmsr49y3rnrin91rv8mpc3dhrf3ql08kbccw8yffq61brfrg";
      type = "gem";
    };
    version = "1.3.1";
  };
}
