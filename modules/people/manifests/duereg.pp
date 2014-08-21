class people::duereg { 
	
}

include nodejs

class {"nodejs::global":
    version => "v0.10.27"
}
  
#
# Install Go via Homebrew
# (the Boxen repo only goes up to Go 1.1
#
package { "go":
    ensure => present,
}
