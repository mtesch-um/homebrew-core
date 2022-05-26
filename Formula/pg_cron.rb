class PgCron < Formula
  desc "Run periodic jobs in PostgreSQL"
  homepage "https://github.com/citusdata/pg_cron"
  url "https://github.com/citusdata/pg_cron/archive/refs/tags/v1.4.1.tar.gz"
  sha256 "f50792baa7105f7e5526ec0dca6d2328e4290131247c305cc84628cd864e9da2"
  license "PostgreSQL"

  depends_on "postgresql"

  def install
    system "make"
    (lib/"postgresql").install "pg_cron.so"
    (share/"postgresql/extension").install Dir["pg_cron--*.sql"]
    (share/"postgresql/extension").install "pg_cron.control"
  end

  def caveats
    <<~EOS
      To complete the installation, load pg_cron in postgresql.conf:
        shared_preload_libraries = 'pg_cron'

      Restart and then create the extension in the database:
        -- run as superuser:
        CREATE EXTENSION pg_cron;
      For more details, read:
        https://github.com/citusdata/pg_cron
    EOS
  end

  test do
    # Testing steps:
    # - create new temporary postgres database
    system "pg_ctl", "initdb", "-D", testpath/"test"

    port = free_port
    # - enable pg_cron in temporary database
    (testpath/"test/postgresql.conf").write("\nshared_preload_libraries = 'pg_cron'\n", mode: "a+")
    (testpath/"test/postgresql.conf").write("\nport =#{port}\n", mode: "a+")

    # - restart temporary postgres
    system "pg_ctl", "start", "-D", testpath/"test", "-l", testpath/"log"

    # - run "CREATE EXTENSION pg_cron;" in temp database
    system "psql", "-p", port.to_s, "-c", "CREATE EXTENSION pg_cron;", "postgres"

    # - shutdown temp postgres
    system "pg_ctl", "stop", "-D", testpath/"test"
  end
end
