class hazelcast(
  $version = '3.3.1',
  $user = 'dev',
  $password = 'dev'
  ){

  $majorVersion = regsubst($version, '^(\d+)\.(\d+).*$', '\1.\2')
  $versions = [ '2.0.4', '2.1.3', '2.2.0', '2.3.1', '2.4.1', '2.5.1', '2.6.7', '3.0.3', '3.1.3', '3.1.4', '3.1.7', '3.2.6', '3.3.1']

  if ! ($version in $versions) {
    fail("The version ${version} is not supported")
  }

  file { "/usr/share/tomcat7/mancenter":
    ensure => directory,
    group => "root",
    owner => "root",
    mode => "0777",
    require => Package['tomcat7']
  }

  file { "/opt/hazelcast":
    ensure => directory,
    group => "root",
    owner => "root",
    mode => "0644",
  }

  exec { "download-hazelcast":
    command => "/usr/bin/wget http://hazelcast.org/files/hazelcast-${version}.zip -P /opt",
    creates => "/opt/hazelcast-${version}.zip"
  }

  exec { "unpack-hazelcast":
    command => "/usr/bin/unzip /opt/hazelcast-${version}.zip -d /opt",
    require => [ Exec["download-hazelcast"], Package['unzip']],
    creates => "/opt/hazelcast-${version}",
  }

  file { "/etc/init/hazelcast.conf":
    ensure => present,
    group => "root",
    owner => "root",
    mode => "0644",
    content => template('hazelcast/hazelcast.conf.erb'),
    require => Package["java"],
    notify => Service["hazelcast"],
  }

  service { 'hazelcast':
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    require => File["/etc/init/hazelcast.conf"],
  }

  file { "/var/lib/tomcat7/webapps/mancenter.war":
    sourceselect => 'first',
    ensure => present,
    group => "root",
    owner => "root",
    mode => "0644",
    source => [
      "/opt/hazelcast-${version}/mancenter.war",
      "/opt/hazelcast-${version}/mancenter-${version}.war",
      "/opt/hazelcast-${version}/mancenter-${majorVersion}.war"
    ],
    require => File["/opt/hazelcast-${version}/bin/hazelcast.xml"],
    notify => Service['tomcat7']
  }

  file { "/opt/hazelcast-${version}/bin/hazelcast.xml":
    ensure => present,
    group => "root",
    owner => "root",
    mode => "0644",
    content => template("hazelcast/hazelcast-${majorVersion}.xml.erb"),
    require => Exec["unpack-hazelcast"],
    notify => Service['hazelcast']
  }
}
