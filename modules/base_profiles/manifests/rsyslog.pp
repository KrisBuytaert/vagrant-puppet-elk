# Base profile to enable rsyslog log shipping
class base_profiles::rsyslog {

  class { '::rsyslog':
    servers => ('192.168.69.5:5544');
  }
}

