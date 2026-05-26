class WrappedDocker < Formula
  desc "Hyper-optimized Rust wrapper for Colima, Podman, and Docker engines"
  homepage "https://github.com/RakibFiha/wrapped-docker"
  version "1.0.0" # Increment this version string when you release a new tag

  # Dynamically fetch the correct archive based on the user's host CPU architecture
  if Hardware::CPU.arm?
    url "https://github.com/RakibFiha/wrapped-docker/releases/download/v#{version}/wrapped-docker-aarch64.tar.gz"
    # Run `shasum -a 256 wrapped-docker-aarch64.tar.gz` on your built asset and paste it here:
    sha256 "8fb4aadb4d7a88d7f60f5584168807983fa59a5848fad6c47872a25b10af3e89"
  else
    url "https://github.com/RakibFiha/wrapped-docker/releases/download/v#{version}/wrapped-docker-x86_64.tar.gz"
    # Run `shasum -a 256 wrapped-docker-x86_64.tar.gz` on your built asset and paste it here:
    sha256 "c030f5127125638a46c4a406b47e37755fac2ae8c8a7466d005be3d6502062a4"
  end

  def install
    # Securely isolates the binary inside Homebrew's internal libexec sandbox
    # This prevents collisions with standard Docker Desktop installations
    libexec.install "docker"
  end

  def post_install
    binary_path = opt_libexec/"docker"

    # 1. Automatically clear the macOS Gatekeeper quarantine flag
    if OS.mac? && binary_path.exist?
      system "xattr", "-d", "com.apple.quarantine", binary_path, errors: :ignore
    end

    # 2. Seamlessly link to ~/.local/bin if the user utilizes that environment structure
    local_bin = Pathname.new("#{ENV["HOME"]}/.local/bin")
    if local_bin.directory?
      target = local_bin/"docker"
      target.rmtree if target.exist? || target.symlink?
      target.make_symlink(binary_path)
      puts "==> Successfully linked wrapped-docker to #{target}"
    end
  end

  def caveats
    <<~EOS
      To ensure your shell prioritizes this hyper-optimized wrapper over default engines,
      verify your terminal environment path order.
      
      If you DO NOT use a ~/.local/bin layout, manually append this line to your ~/.zshrc or ~/.bashrc:
        export PATH="#{opt_libexec}:$PATH"
    EOS
  end

  test do
    # Simple verification smoke test to ensure the binary runs and returns execution details
    assert_match "version", shell_output("#{libexec}/docker --version")
  end
end
