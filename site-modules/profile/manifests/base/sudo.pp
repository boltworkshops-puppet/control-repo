# Class: profile::base::sudo
#
#
class profile::base::sudo {
  include sudo

  sudo::conf { 'wheel':
    priority => 10,
    content  => '%wheel ALL=(ALL) NOPASSWD: ALL',
  }

  if $facts['virtual'] == 'gce' and $facts['kernel'] == 'Linux' {
    # Just make sure the file is there, it's "managed" by google
    file { '/etc/sudoers.d/google-oslogin':
      ensure => file,
    }
  }
}
