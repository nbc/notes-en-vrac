library(duckdb)
library(tictoc)
library(tibble)

con <- dbConnect(duckdb(), dbdir = "rgs.db", memory_limit = "20G")

#dbGetQuery(con, "SELECT * FROM parquet_metadata('/home/nc/travail/R/Rexploration/rdata/nyc-taxi/year=2021/month=7/part-0.parquet')")

input_rgs = tibble(input = c(5000, 10000, 20000, 40000, 80000, 160000))
output_rgs = tibble(output = c(5000, 10000, 20000, 40000, 80000, 160000))
threads = tibble(threads = c(1, 2, 5, 10))

duckdb_register(con, "input_rgs", input_rgs, overwrite = TRUE)
duckdb_register(con, "output_rgs", output_rgs, overwrite = TRUE)
duckdb_register(con, "threads", threads, overwrite = TRUE)

dbGetQuery(con, "SELECT * FROM input_rgs, output_rgs, threads OFFSET 10 LIMIT 1")

for (i in c(5000, 50000, 100000, 500000, 1000000, 10000000)) {
  tic()
  dbExecute(con, glue("COPY (SELECT * FROM read_parquet('/home/nc/travail/R/Rexploration/rdata/nyc-taxi/year=2017/**/*.parquet')) TO 'test_{rgs}.parquet' (FORMAT PARQUET, ROW_GROUP_SIZE {rgs})"))
  toc()
}
Sys.getpid()
