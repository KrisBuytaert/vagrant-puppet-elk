# The ElasticSearch, Logstash , Kibana Profile
class profile_elk {
  notify {'elks are so lovely': }





#
# Logstash
#

  $config_hash = { 'START' => true, }
  class { 'logstash':
    ensure        => 'present',
    init_defaults => $config_hash,
    java_install  => true,
    status        => 'enabled',
    require       => Yumrepo['logstashrepo'],
  }

  logstash::configfile { 'input':
    content => '
    input {
      syslog {
        type => "syslog"
        port => "5544"
      }
      }',
      order => 10,
  }

  logstash::configfile { 'output':
    content => '
    output {
      elasticsearch {
        host  => "localhost"
      }
      }',
      order => 20,
  }

  #
  # Elasticsearch
  #

  class { 'elasticsearch':
    status  => 'running',
    require => Yumrepo['Elasticsearch repository for 0.90.x packages'],
    version => '0.90.9-1',
  }

  #
  # Rsyslog config to put all the things to localhost:5544
  # The part below will be configured in our default rsyslog setup
  #

  #  file_line { 'Configuring rsyslog':
  #    path    => '/etc/rsyslog.conf',
  #    line    => '*.* @localhost:5544',
  #    match   => '\*\.\*\s\@',
  #    notify  => Service['service rsyslogd restart']
  #  }

  # service { 'service rsyslogd restart':
  #    name        => 'rsyslog',
  #    hasrestart  => true,
  #    restart     => '/sbin/service rsyslog restart',
  #  }

  #
  # Yumrepos
  #

  # Yumrepos should not be part of a manifest
  # Also we should not be using external repositories
  # Disabled a number of repositories on purpose to make sure they don't get
  # installed accidently
  #


  # Adding the yumrepo for logstash

  yumrepo { 'logstash':
    name     => 'logstash',
    baseurl  => 'http://packages.elasticsearch.org/logstash/1.3/centos',
    gpgcheck => 1,
    gpgkey   => 'http://packages.elasticsearch.org/GPG-KEY-elasticsearch',
    enabled  => 1,
  }

  # Adding yumrepo for elasticsearch

  yumrepo { 'elasticsearch':
    name     => 'elasticsearch',
    baseurl  => 'http://packages.elasticsearch.org/elasticsearch/1.4/centos',
    gpgcheck => 1,
    gpgkey   => 'http://packages.elasticsearch.org/GPG-KEY-elasticsearch',
    enabled  => 1,
  }

  #  package { 'redis':
  #    ensure  => 'present',
  #    #  require => Yumrepo['epel'],
  #  }

  #  package { 'ruby': ensure  => 'present'; }
  #  package { 'rubygems': ensure  => 'present'; }
  #  package { 'ruby-devel': ensure  => 'present'; }

  ### Kibana 3

  package { 'kibana3-html': ensure  => 'present'; }


}
