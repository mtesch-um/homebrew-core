class PgPartman < Formula
  desc "Partition management extension for PostgreSQL"
  homepage "https://github.com/pgpartman/pg_partman"
  url "https://github.com/pgpartman/pg_partman/archive/refs/tags/v4.6.2.tar.gz"
  sha256 "81ec4371985fd2f95ce4321b63371c0a308d476e57e6a4b7a5e23d73a5e4b218"
  license "PostgreSQL"

  depends_on "postgresql"

  def install
    system "make"
    (prefix/"lib/postgresql").install "src/pg_partman_bgw.so"
    (prefix/"share/postgresql/extension").install "pg_partman.control"
    (prefix/"share/postgresql/extension").install Dir["updates/pg_partman--*.sql"]
  end

  def caveats
    <<~EOS
      To complete the installation, load pg_partman_bgw in postgresql.conf:
        shared_preload_libraries = 'pg_partman_bgw'

      Restart and then create the extension in the database:
        -- run as superuser:
        CREATE EXTENSION pg_partman_bgw;
      For more details, read:
        https://github.com/pgpartman/pg_partman
    EOS
  end

  test do
    # Testing steps:
    # - create new temporary postgres database
    system "pg_ctl", "initdb", "-D", testpath/"test"

    # - enable pg_partman in temporary database
    File.write(testpath/"test/postgresql.conf", "\nshared_preload_libraries = 'pg_partman_bgw'\n", mode: "a+")
    File.write(testpath/"test/postgresql.conf", "\nport = 5562\n", mode: "a+")

    # - restart temporary postgres
    system "pg_ctl", "start", "-D", testpath/"test", "-l", testpath/"log"

    # - create extension in temp database
    system "psql", "-p", "5562", "-c", "CREATE SCHEMA partman; CREATE EXTENSION pg_partman SCHEMA partman;", "postgres"

    # - shutdown temp postgres
    system "pg_ctl", "stop", "-D", testpath/"test"
  end
end
