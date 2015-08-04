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
    require       => Yumrepo['logstash'],
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
        cluster  => "playground"
      }
      }',
      order => 20,
  }

  #
  # Elasticsearch
  #

  class { 'elasticsearch':
    config  => {'cluster.name'           => 'playground' },
    status  => 'running',
    require => Yumrepo['elasticsearch'],
  }

  #

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
    baseurl  => 'http://packages.elasticsearch.org/logstash/1.4/centos',
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

  class {'kibana3':
    elasticsearch_server => 'http://"+window.location.hostname+"/_es',
  }


  ### Apache


  class { 'apache': }


  apache::vhost { 'kibana.playground.ing':
    port       => '80',
    docroot    => '/var/vhosts/kibana3/htdocs',
    proxy_pass => [
      { 'path' => '/_es', 'url'                   => "http://${fqdn}:9200/" },
      { 'path' => '/_aliases', 'url'              => "http://${fqdn}:9200/_aliases" },
      { 'path' => '/_status', 'url'               => "http://${fqdn}:9200/_status" },
      { 'path' => '/_plugin', 'url'               => "http://${fqdn}:9200/_plugin" },
      { 'path' => '/kibana-int/dashboard/', 'url' => "http://${fqdn}:9200/kibana-int/dashboard/" },
      { 'path' => '/kibana-int/temp/', 'url'      => "http://${fqdn}:9200/kibana-int/temp/" },
      { 'path' => '/(.*)/_search', 'url'          => "http://${fqdn}:9200/$1/_search" },
    ]
  }

  class { 'kibana4':
    port => 8081,
  }

}
