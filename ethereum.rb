require 'formula'

class Ethereum < Formula

  # official_version-protocol_version
  version '0.9.22-60'

  homepage 'https://github.com/ethereum/go-ethereum'
  url 'https://github.com/ethereum/go-ethereum.git', :branch => 'master'

  bottle do
    revision 150
    root_url 'https://build.ethdev.com/builds/OSX%20Go%20master%20brew/150/bottle'
    sha1 '43f7a42be7acc2fda78d3a731c8b6d98561226cd' => :yosemite
  end

  devel do
    bottle do
      revision 578
      root_url 'https://build.ethdev.com/builds/OSX%20Go%20develop%20brew/578/bottle'
      sha1 '63cea5059994b8f23fec71556b5c79451a3901c8' => :yosemite
    end

    version '0.9.22-60'
    url 'https://github.com/ethereum/go-ethereum.git', :branch => 'develop'
  end

  depends_on 'go' => :build
  depends_on 'hg' => :build
  depends_on 'pkg-config' => :build
  depends_on 'qt5' if build.include? 'with-gui'
  depends_on 'readline'
  depends_on 'gmp'

  option 'with-gui', "Build with GUI (Mist)"

  def install
    base = "src/github.com/ethereum/go-ethereum"

    ENV["PKG_CONFIG_PATH"] = "#{HOMEBREW_PREFIX}/opt/qt5/lib/pkgconfig"
    ENV["QT5VERSION"] = `pkg-config --modversion Qt5Core`
    ENV["CGO_CPPFLAGS"] = "-I#{HOMEBREW_PREFIX}/opt/qt5/include/QtCore"
    ENV["GOPATH"] = "#{buildpath}/#{base}/Godeps/_workspace:#{buildpath}"
    ENV["GOROOT"] = "#{HOMEBREW_PREFIX}/opt/go/libexec"
    ENV["PATH"] = "#{ENV['GOPATH']}/bin:#{ENV['PATH']}"

    # Debug env
    system "go", "env"

    # Move checked out source to base
    mkdir_p base
    Dir["**"].reject{ |f| f['src']}.each do |filename|
      move filename, "#{base}/"
    end

    cmd = "#{base}/cmd/"

    system "go", "build", "-v", "./#{cmd}geth"
    system "go", "build", "-v", "./#{cmd}mist" if build.include? "with-gui"

    bin.install 'geth'
    bin.install 'mist' if build.include? "with-gui"

    move "#{cmd}mist/assets", prefix/"Resources"
  end

  test do
    system "geth"
    system "mist" if build.include? "with-gui"
  end

  def plist; <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
      <dict>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>RunAtLoad</key>
        <true/>
        <key>KeepAlive</key>
        <true/>
        <key>ThrottleInterval</key>
        <integer>300</integer>
        <key>ProgramArguments</key>
        <array>
            <string>#{opt_bin}/geth</string>
            <string>-datadir=#{prefix}/.ethereum</string>
        </array>
        <key>WorkingDirectory</key>
        <string>#{HOMEBREW_PREFIX}</string>
      </dict>
    </plist>
    EOS
  end
end
__END__
