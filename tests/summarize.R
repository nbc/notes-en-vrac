library(duckdb)
library(tictoc)

con <- DBI::dbConnect(duckdb())
taxi_dir <- "/home/nc/travail/R/Rexploration/rdata/nyc-taxi"
glue::glue("read_parquet('{taxi_dir}/**/*.parquet')")

tic()
dbGetQuery(con, glue::glue("SUMMARIZE SELECT * FROM read_parquet('{taxi_dir}/**/*.parquet') WHERE year == 2016 AND month == 1"))
toc()

tic()
dbGetQuery(con, glue::glue("SELECT * FROM read_parquet('{taxi_dir}/**/*.parquet') WHERE year == 2016 AND month == 1  USING SAMPLE 10"))
toc()
