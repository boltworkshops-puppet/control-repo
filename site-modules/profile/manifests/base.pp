class profile::base {
  include profile::base::additional_packages
  include profile::base::security
  include profile::base::repos
}
