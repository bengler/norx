node default {

	include sudo

  user { "kartverk":
    ensure => present,
    shell => "/bin/bash",
    home => "/home/kartverk",
    managehome => true,
    password => '$1$v2LPD8H2$RYDI3B4/0ak5kSCrLjpls/' # bengler
  }

  augeas { "addkartverktosudoers":
    context => "/files/etc/sudoers",
    changes => [
      "set spec[user = 'kartverk']/user kartverk",
      "set spec[user = 'kartverk']/host_group/host ALL",
      "set spec[user = 'kartverk']/host_group/command ALL",
      "set spec[user = 'kartverk']/host_group/command/runas_user ALL",
    ]
  }

}
