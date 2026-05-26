class Wocker < Formula
  desc "Hyper-optimized Rust wrapper for Colima, Podman, and Docker engines"
  homepage "https://github.com/RakibFiha/wrapped-docker"
  version "1.0.0"

  if Hardware::CPU.arm?
    # 👇 Points to your existing release tar file asset name
    url "https://github.com/RakibFiha/wrapped-docker/releases/download/v#{version}/wrapped-docker-aarch64.tar.gz"
    sha256 "8fb4aadb4d7a88d7f60f5584168807983fa59a5848fad6c47872a25b10af3e89"
  else
    url "https://github.com/RakibFiha/wrapped-docker/releases/download/v#{version}/wrapped-docker-x86_64.tar.gz"
    sha256 "c030f5127125638a46c4a406b47e37755fac2ae8c8a7466d005be3d6502062a4"
  end

  def install
    # Extracts the "wrapped-docker" binary from the tar file, but installs it as "wocker"
    bin.install "docker" => "wocker"
  end

  def post_install
    binary_path = bin/"wocker"
    if OS.mac? && binary_path.exist?
      system "xattr -d com.apple.quarantine #{binary_path} 2>/dev/null"
    end
  end

  test do
    assert_match "version", shell_output("#{bin}/wocker --version")
  end
end
