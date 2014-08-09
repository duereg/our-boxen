require boxen::environment
require homebrew
require gcc

Exec {
  group       => 'staff',
  logoutput   => on_failure,
  user        => $boxen_user,

  path => [
    "${boxen::config::home}/rbenv/shims",
    "${boxen::config::home}/rbenv/bin",
    "${boxen::config::home}/rbenv/plugins/ruby-build/bin",
    "${boxen::config::home}/homebrew/bin",
    '/usr/bin',
    '/bin',
    '/usr/sbin',
    '/sbin'
  ],

  environment => [
    "HOMEBREW_CACHE=${homebrew::config::cachedir}",
    "HOME=/Users/${::boxen_user}"
  ]
}

File {
  group => 'staff',
  owner => $boxen_user
}

Package {
  provider => homebrew,
  require  => Class['homebrew']
}

Repository {
  provider => git,
  extra    => [
    '--recurse-submodules'
  ],
  require  => File["${boxen::config::bindir}/boxen-git-credential"],
  config   => {
    'credential.helper' => "${boxen::config::bindir}/boxen-git-credential"
  }
}

Service {
  provider => ghlaunchd
}

Homebrew::Formula <| |> -> Package <| |>

node default {
  # core modules, needed for most things
  include dnsmasq
  include git
  include hub
  include nginx

  # node versions
  include nodejs::v0_6
  include nodejs::v0_8
  include nodejs::v0_10

  # default ruby versions
  ruby::version { '1.9.3': }
  ruby::version { '2.0.0': }
  ruby::version { '2.1.0': }
  ruby::version { '2.1.1': }
  ruby::version { '2.1.2': }

  # common, useful packages
  package {
    [
      'ack',
      'findutils',
      'gnu-tar'
    ]:
  }

  file { "${boxen::config::srcdir}/our-boxen":
    ensure => link,
    target => $boxen::config::repodir
  }

  include atom
  include chrome::dev
  include chrome::canary
  include dropbox
  include firefox
  include foreman
  include go
  include gcc
  include github_for_mac
  include gitx::dev
  include googledrive
  include heroku
  include imagemagick
  include iterm2::dev
  include java
  include macvim
  include mongodb
  include mysql
  include phantomjs
  include postgresapp
  include postgresql
  include python
  include onepassword
  include osx
  include redis
  include skype
  include solr
  include sublime_text
  include sublime_text::package_control
  include vagrant
  include virtualbox
  include vlc
  include zsh

  # install any arbitrary nodejs version
  nodejs::version { 'v0.10.29’: }

  # set the global nodejs version
  class { 'nodejs::global': version => 'v0.10.29’ }

  # install some npm modules
  nodejs::module { 'bower':
    node_version => 'v0.10.29’
  }

  sublime_text::package { 'Emmet':
    source => 'sergeche/emmet-sublime'
  }

  # osx configuration
  # https://github.com/boxen/puppet-osx
  include osx::disable_app_quarantine
  include osx::dock::autohide
  include osx::global::disable_key_press_and_hold
  include osx::global::enable_keyboard_control_access
  include osx::global::expand_print_dialog
  include osx::global::expand_save_dialog
  include osx::global::key_repeat_rate
  include osx::no_network_dsstores

  class { 'osx::global::key_repeat_delay':
    delay => 0
  }

  class { 'osx::dock::icon_size':
    size => 36
  }

  include projects::all
}
