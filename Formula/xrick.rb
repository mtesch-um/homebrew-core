class Xrick < Formula
  desc "Clone of Rick Dangerous"
  homepage "https://www.bigorno.net/xrick/"
  url "https://www.bigorno.net/xrick/xrick-021212.tgz"
  # There is a repo at https://github.com/zpqrtbnk/xrick but it is organized
  # differently than the tarball
  sha256 "aa8542120bec97a730258027a294bd16196eb8b3d66134483d085f698588fc2b"
  revision 1

  bottle do
    sha256 arm64_monterey: "b97026a329519f349a0895a8d13f1bbd4b59fd10e5eaaed246bf2f98d99b5b49"
    sha256 arm64_big_sur:  "30b4c69fa6b25347123661e07a58e1ce0feb383533b7f5a0b997edd2ea804221"
    sha256 monterey:       "8bac12edddcd4707b5404c98f1e0d7af073154ffee46f3e4ddca9251a0e8ec26"
    sha256 big_sur:        "3f344cdf41f15e2b82d5ce3557db8e05cdafd6d9cc50b3f78a4ab67af4906e15"
    sha256 catalina:       "0834c07da50760edddf5263d5169bd27edeff0b5765795a535b637b14c823a59"
  end

  depends_on "sdl12-compat"

  uses_from_macos "zlib"

  def install
    inreplace "src/xrick.c", "data.zip", "#{pkgshare}/data.zip"
    system "make"
    bin.install "xrick"
    man6.install "xrick.6.gz"
    pkgshare.install "data.zip"
  end

  test do
    assert_match "xrick [version ##{version}]", shell_output("#{bin}/xrick --help", 1)
  end
end
