class timezone::params {
  case $::operatingsystem {
    /(Ubuntu|Debian)/: {
      $package = 'tzdata'
      $zoneinfo_dir = '/usr/share/zoneinfo/'
      $config_file = '/etc/timezone'
      $update_command = 'dpkg-reconfigure -f noninteractive tzdata'
    }
    /(RedHat|CentOS)/: {
      $package = 'tzdata'
      $zoneinfo_dir = '/usr/share/zoneinfo/'
      $config_file = '/etc/sysconfig/clock'
      $update_command = 'tzdata-update'
    }
    default: {
      fail("Unsupported platform: ${::operatingsystem}")
    }
  }
}
