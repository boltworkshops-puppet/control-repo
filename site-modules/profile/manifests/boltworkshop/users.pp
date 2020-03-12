# @summary
#   Class to allow the management of local users for the bolt workshop
#
# @param number How many local users should be created?
#
# @example
#   class { 'profile::boltworkshop::users':
#     number => '15',
#   }
#
class profile::boltworkshop::users (
  String $number = $facts['students'],
){

  $users = range('0', $number)
  $gitremote = lookup('profile::boltworkshop::users::gitremote',Sensitive,first,undef)

  case $facts['kernel'] {
    'Windows': {
      group { 'students':
        ensure => present,
      }

      $user_pass = lookup('profile::boltworkshop::users::password',Sensitive,first,undef)

      windows_env { 'PATH=C:\\Program Files\\git\\': }

      $users.each | Integer $user_number | {
        $id = "student${user_number}"
        user { $id:
          ensure     => present,
          groups     => ['students'],
          home       => "C:/Users/${id}",
          managehome => true,
          password   => Sensitive($user_pass),
        }

        file { "C:/Users/${id}/labfiles":
          ensure => directory,
          owner  => $id,
          group  => 'students',
        }

        vcsrepo { "C:/Users/${id}/labfiles":
          ensure   => present,
          provider => git,
          source   => Sensitive($gitremote),
          revision => 'master',
          require  => [Package['git'],Windows_env['PATH=C:\\Program Files\\git\\']],
        }

      }

      #class { 'vscode':
      #  package_ensure => 'present',
      #}

      #vscode_extension { 'jpogran.puppet':
      #  ensure  => 'present',
      #  require => Class['vscode'],
      #}
    }
    'Linux': {
      group { 'students':
        ensure => present,
      }

      $user_pass = pw_hash(lookup('profile::boltworkshop::users::password',Sensitive,first,undef),'SHA-512',String(fqdn_rand(60)))


      $users.each | Integer $user_number | {
        $id = "student${user_number}"
        user { $id:
          ensure     => present,
          gid        => 'students',
          home       => "/home/${id}",
          shell      => '/bin/bash',
          managehome => true,
          password   => Sensitive($user_pass),
        }

        file { "/home/${id}/labfiles":
          ensure => directory,
          owner  => $id,
          group  => 'students',
          mode   => '0644',
        }

        file { "/home/${id}/.ssh":
          ensure => directory,
          mode   => '0700',
          owner  => $id,
          group  => 'students',
        }

        file { "/home/${id}/.ssh/config":
          ensure  => file,
          owner   => $id,
          group   => 'students',
          mode    => '0600',
          content => "Host *\nStrictHostKeyChecking no\nUserKnownHostFile=/dev/null\n",
        }

        file { "/home/${id}/.gitconfig":
          ensure  => file,
          owner   => $id,
          group   => 'students',
          mode    => '0600',
          content => "[user]\n\tname = boltworkshops-puppet\n\temail = boltworkshops@puppet.com\n",
        }

        file { "/home/${id}/.nanorc":
          ensure  => file,
          mode    => '0600',
          owner   => $id,
          group   => 'students',
          content => "set const\n"
        }

        vcsrepo { "/home/${id}/labfiles":
          ensure   => present,
          provider => git,
          source   => Sensitive($gitremote),
          revision => 'master',
          require  => Package['git'],
        }

        file { "/home/${id}/.vim":
          ensure  => directory,
          owner   => $id,
          group   => 'students',
          source  => "puppet:///modules/${module_name}/boltworkshop/vim/vim",
          recurse => true,
        }

        file { "/home/${id}/.vimrc":
          ensure  => file,
          owner   => $id,
          group   => 'students',
          content => epp('profile/boltworkshop/vimrc.epp', {
            'syntax'   => 'on',
            'hlsearch' => 'hlsearch',
            't_Co'     => 't_Co=256',
            'line_num' => 'number',
          }),
        }
      }
    }
    default: {}
  }
}
