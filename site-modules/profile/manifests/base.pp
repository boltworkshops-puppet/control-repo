class profile::base {
  include profile::base::repos
  include profile::base::additional_packages
  include profile::base::security
}
