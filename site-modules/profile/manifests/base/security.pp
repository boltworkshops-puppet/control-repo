# @summary Security profile to manage access and selinux
#
# @example
#   include profile::base::security
#
class profile::base::security {

  case $facts['kernel'] {
    'Linux': {
      include profile::base::sudo
      class { 'selinux':
        mode => 'disabled',
      }
    }
    default: {}
}
