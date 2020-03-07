# Class: profile::base::repos
#
#
class profile::base::repos {
  class { 'yum':
    keep_kernel_devel       => false,
    clean_old_kernels       => true,
    manage_os_default_repos => true,
    notify                  => Exec['yum clean all'],
  }

  # ensure that cache is cleaned out if we update settings
  exec { 'yum clean all':
    path        => '/usr/bin/',
    command     => 'yum clean all',
    refreshonly => true,
  }
}
