{
  concurrent-ruby = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0nwad3211p7yv9sda31jmbyw6sdafzmdi2i2niaz6f0wk5nq9h0f";
      type = "gem";
    };
    version = "1.1.9";
  };
  deep_merge = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1q3picw7zx1xdkybmrnhmk2hycxzaa0jv4gqrby1s90dy5n7fmsb";
      type = "gem";
    };
    version = "1.2.1";
  };
  diff-lcs = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0m925b8xc6kbpnif9dldna24q1szg4mk0fvszrki837pfn46afmz";
      type = "gem";
    };
    version = "1.4.4";
  };
  facter = {
    dependencies = ["hocon" "thor"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1mhq4rmyc60ijzw6f6sbphyb76vlwcgbaqyqw6y7wb8qdisn19wc";
      type = "gem";
    };
    version = "4.2.5";
  };
  facterdb = {
    dependencies = ["facter" "jgrep"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0s15yw9x1cs5r5r8higv5x5dhjwnvb33xbq1yicwnpvcr1636i2q";
      type = "gem";
    };
    version = "1.12.1";
  };
  fast_gettext = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "02s9qrvxi9fcvsrwz4hisrv0q13gdv5vr1rjn2ywpdw0kjg9csb6";
      type = "gem";
    };
    version = "1.8.0";
  };
  hiera = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1g1bagbb4lvs334gpqyylvcrs7h6q2kn1h162dnvhzqa4rzxap8a";
      type = "gem";
    };
    version = "3.7.0";
  };
  hocon = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0mifv4vfvppfdpkd0cwgy634sj0aplz6ys84sp8s11qrnm6vlnmn";
      type = "gem";
    };
    version = "1.3.1";
  };
  httpclient = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "19mxmvghp7ki3klsxwrlwr431li7hm1lczhhj8z4qihl2acy8l99";
      type = "gem";
    };
    version = "2.8.3";
  };
  jgrep = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1ns4zsxgwz6f9grrggms8pf4x9ifkv91f74mcm6kn447hrc8a5aj";
      type = "gem";
    };
    version = "1.5.4";
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
  mocha = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "15s53ggsykk69kxqvs4416s8yxdhz6caggva55n8sjgy4ixzwp10";
      type = "gem";
    };
    version = "1.13.0";
  };
  multi_json = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0pb1g1y3dsiahavspyzkdy39j4q377009f6ix0bh1ag4nqw43l0z";
      type = "gem";
    };
    version = "1.15.0";
  };
  pathspec = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1r4q5qw5yihv8m8z102glzrk8r9g30hgbpzw5izhk63w6qnx22kh";
      type = "gem";
    };
    version = "1.0.0";
  };
  puppet = {
    dependencies = ["concurrent-ruby" "deep_merge" "facter" "fast_gettext" "hiera" "httpclient" "locale" "multi_json" "puppet-resource_api" "semantic_puppet"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "169z06mslkzwwy2v0m20mdlcmisxz1p2rd8c6nqm8h7dhbcg6rrh";
      type = "gem";
    };
    version = "6.25.1";
  };
  puppet-lint = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1rcj3cb6lf90g6vvhh3c9p8yn7pgibglf9k5878bzd6pn5ag0h9v";
      type = "gem";
    };
    version = "2.5.2";
  };
  puppet-resource_api = {
    dependencies = ["hocon"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1dchnnrrx0wd0pcrry5aaqwnbbgvp81g6f3brqhgvkc397kly3lj";
      type = "gem";
    };
    version = "1.8.14";
  };
  puppet-syntax = {
    dependencies = ["puppet" "rake"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1jj10pb25scq3fjnxrcb93zmwqhad53ccxq2y639yj8w38mygv2q";
      type = "gem";
    };
    version = "3.1.0";
  };
  puppetlabs_spec_helper = {
    dependencies = ["mocha" "pathspec" "puppet-lint" "puppet-syntax" "rspec-puppet"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "01qm0va9mbfj6hg90kmglalhnjrqrhza53r29iyr751sn22cqac2";
      type = "gem";
    };
    version = "4.0.1";
  };
  rake = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "15whn7p9nrkxangbs9hh75q585yfn66lv0v2mhj6q6dl6x8bzr2w";
      type = "gem";
    };
    version = "13.0.6";
  };
  rspec = {
    dependencies = ["rspec-core" "rspec-expectations" "rspec-mocks"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1dwai7jnwmdmd7ajbi2q0k0lx1dh88knv5wl7c34wjmf94yv8w5q";
      type = "gem";
    };
    version = "3.10.0";
  };
  rspec-core = {
    dependencies = ["rspec-support"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0wwnfhxxvrlxlk1a3yxlb82k2f9lm0yn0598x7lk8fksaz4vv6mc";
      type = "gem";
    };
    version = "3.10.1";
  };
  rspec-expectations = {
    dependencies = ["diff-lcs" "rspec-support"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1sz9bj4ri28adsklnh257pnbq4r5ayziw02qf67wry0kvzazbb17";
      type = "gem";
    };
    version = "3.10.1";
  };
  rspec-mocks = {
    dependencies = ["diff-lcs" "rspec-support"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1d13g6kipqqc9lmwz5b244pdwc97z15vcbnbq6n9rlf32bipdz4k";
      type = "gem";
    };
    version = "3.10.2";
  };
  rspec-puppet = {
    dependencies = ["rspec"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "08rhlymdb92gl4bnjl5aa65bcjww0nfqaanhrpvd7wir7wybn3g7";
      type = "gem";
    };
    version = "2.11.0";
  };
  rspec-puppet-facts = {
    dependencies = ["facter" "facterdb" "puppet"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1z0g4j6ycwl863q744n1k2n26qsig74ay750d2dwiyg1lx86q953";
      type = "gem";
    };
    version = "2.0.3";
  };
  rspec-support = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0pjckrh8q6sqxy38xw7f4ziylq1983k84xh927s6352pps68zj35";
      type = "gem";
    };
    version = "3.10.3";
  };
  semantic_puppet = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0gg1bizlgb8wswxwy3irgppqvd6mlr27qsp0fzpm459wffzq10sx";
      type = "gem";
    };
    version = "1.0.4";
  };
  thor = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "18yhlvmfya23cs3pvhr1qy38y41b6mhr5q9vwv5lrgk16wmf3jna";
      type = "gem";
    };
    version = "1.1.0";
  };
}
