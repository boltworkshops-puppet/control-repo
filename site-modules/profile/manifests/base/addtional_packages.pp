# @summary
#   Manage additional packages defined in hiera or through parameters
#
# @example Basic usage
#   include profile::base::additional_packages
#
# @example Hiera values
#   profile::base::additional_packages:
#     yum-utils:
#       ensure: 'installed'
#
# @example Providing parameters
#   class profile::base::additional_packages {
#     packages => { 'yum-utils': { 'ensure': 'installed'}}
#   }
class profile::base::additional_packages (
  Hash $packages = {}
){
  $hiera_packages = lookup('profile::base::packages',Hash,deep,{})

  $full_packages = merge($hiera_packages, $packages)

  $full_packages.each | String $package, Hash $options | {
    case $options['ensure'] {
      /\d.*/: {
        profile::base::pinned_package { $package:
          version => $options['ensure'],
        }
      }
      default: {
        package { $package:
          * => $options,
        }
      }
    }
  }
}
