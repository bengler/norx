node default {

	include sudo

  user { "norx":
    ensure => present,
    shell => "/bin/bash",
    home => "/home/norx",
    managehome => true,
    password => '$1$v2LPD8H2$RYDI3B4/0ak5kSCrLjpls/' # bengler
  }

  augeas { "addnorxtosudoers":
    context => "/files/etc/sudoers",
    changes => [
      "set spec[user = 'norx']/user norx",
      "set spec[user = 'norx']/host_group/host ALL",
      "set spec[user = 'norx']/host_group/command ALL",
      "set spec[user = 'norx']/host_group/command/runas_user ALL",
    ]
  }

}
