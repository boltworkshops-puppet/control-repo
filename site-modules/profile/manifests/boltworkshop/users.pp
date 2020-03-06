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
  Integer $number = '15',
){
  case $facts['kernel'] {
    'Linux': {
      group { 'students':
        ensure => present,
      }

      $user_pass = lookup('profile::boltworkshop::users::password',Sensitive,first,undef)

      $users = range('0', $number)

      $users.each | $user_number | {
        $id = "student${user_number}"
        user { $id:
          ensure   => present,
          gid      => 'students',
          home     => "/home/${id}",
          shell    => '/bin/bash',
          password => Sensitive($user_pass),
        }

        File {
          owner  => $id,
          group  => 'students',
          mode   => '0644',
        }

        file { "/home/${id}/labfiles":
          ensure => directory,
        }

        file { "/home/${id}/.ssh":
          ensure => directory,
          mode   => '0700',
        }

        file { "/home/${id}/.ssh/config":
          ensure  => file,
          mode    => '0600',
          content => "Host *\nStrictHostKeyChecking no\nUserKnownHostFile=/dev/null\n",
        }

        file { "/home/${id}/.gitconfig":
          ensure  => file,
          mode    => '0600',
          content => "[user]\n\tname = boltworkshops-puppet\n\temail = boltworkshops@puppet.com\n",
        }

        file { "/home/${id}/.nanorc":
          ensure  => file,
          mode    => '0600',
          content => "set const\n"
        }

        file { "/home/${id}/.gitconfig":
          ensure  => file,
          mode    => '0600',
          content => "set number\n",
        }

        $gitremote = lookup('profile::boltworkshop::users::gitremote',Sensitive,first,undef)

        vcsrepo { "/home/${id}/labfiles":
          ensure   => present,
          provider => git,
          source   => Sensitive($gitremote),
          revision => 'master',
        }

      }
    }
    default: {}
  }