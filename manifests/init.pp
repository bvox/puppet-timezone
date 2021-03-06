# Class: timezone
#
# This module manages timezone settings
#
# Parameters:
#   [*timezone*]
#     The name of the timezone.
#     Default: UTC
#
#   [*ensure*]
#     Ensure if present or absent.
#     Default: present
#
#   [*autoupgrade*]
#     Upgrade package automatically, if there is a newer version.
#     Default: false
#
#   [*package*]
#     Name of the package.
#     Only set this, if your platform is not supported or you know, what you're doing.
#     Default: auto-set, platform specific
#
#   [*config_file*]
#     Main configuration file.
#     Only set this, if your platform is not supported or you know, what you're doing.
#     Default: auto-set, platform specific
#
#   [*zoneinfo_dir*]
#     Source directory of zoneinfo files.
#     Only set this, if your platform is not supported or you know, what you're doing.
#     Default: auto-set, platform specific
#
# Actions:
#   Installs tzdata and configures timezone
#
# Requires:
#   Nothing
#
# Sample Usage:
#   class { 'timezone':
#     timezone => 'Europe/Berlin',
#   }
#
# [Remember: No empty lines between comments and class definition]
class timezone (
  $timezone = 'UTC',
  $ensure = 'present',
  $autoupgrade = false,
  $package = $timezone::params::package,
  $config_file = $timezone::params::config_file,
  $zoneinfo_dir = $timezone::params::zoneinfo_dir,
  $update_command = $timezone::params::update_command
) inherits timezone::params {

  case $ensure {
    /(present)/: {
      if $autoupgrade == true {
        $package_ensure = 'latest'
        } else {
          $package_ensure = 'present'
        }
        $config_ensure = 'present'
    }
    /(absent)/: {
      # Leave package installed, as it is a system dependency
      $package_ensure = 'present'
      $config_ensure = 'absent'
    }
    default: {
      fail('ensure parameter must be present or absent')
    }
  }

  package { $package:
    ensure => $package_ensure,
  }

  $config_file_contents = $::operatingsystem ? {
    /(Debian|Ubuntu)/ => "${timezone}\n",
    /(RedHat|CentOS)/ => "ZONE=\"${timezone}\"",
  }

  file { $config_file:
    ensure  => $config_ensure,
    content => $config_file_contents,
    require => Package[$package],
  }

  exec { $update_command :
    require     => File[$config_file],
    subscribe   => File[$config_file],
    path        => '/usr/local/sbin:/sbin:/bin:/usr/sbin:/usr/bin',
    refreshonly => true,
  }
}
