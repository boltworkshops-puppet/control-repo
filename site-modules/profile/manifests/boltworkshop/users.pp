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
  Integer $number = $facts['students'],
){
  case $facts['kernel'] {
    'Linux': {
      group { 'students':
        ensure => present,
      }

      $user_pass = lookup('profile::boltworkshop::users::password',Sensitive,first,undef)

      $users = range('0', $number)

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

        $gitremote = lookup('profile::boltworkshop::users::gitremote',Sensitive,first,undef)

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
