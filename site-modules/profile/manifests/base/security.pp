# @summary Security profile to manage access and selinux
#
# @example
#   include profile::base::security
#
class profile::base::security {
  class { 'selinux':
    mode => 'disabled',
  }


}
