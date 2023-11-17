library(duckdb)
library(tidyverse)
library(tictoc)

con <- dbConnect(duckdb(),
                 dbdir = "tuto_duckdb.db",
                 config = list(memory_limit = "100G", threads = "4"))


customer <- tbl(con, "read_parquet('/nfs/partage-r-sas/exemples/tpch/customer.parquet')")
orders <- tbl(con, "read_parquet('/nfs/partage-r-sas/exemples/tpch/orders_parquet/**/*.parquet')")
lineitem <- tbl(con, "read_parquet('/nfs/partage-r-sas/exemples/tpch/lineitem.parquet')")

tic()
customer |>
  inner_join(orders, by = join_by(C_CUSTKEY == O_CUSTKEY)) |>
  inner_join(lineitem, by = join_by(O_ORDERKEY == L_ORDERKEY)) |>
  summarize(customer_nb = n_distinct(C_CUSTKEY),
            quantity = sum(L_QUANTITY),
            total_price = sum(O_TOTALPRICE)) |>
  collect()
toc()

dbDisconnect(con, shutdown = TRUE)

library(duckdb)
library(tidyverse)
library(tictoc)

con <- dbConnect(duckdb(),
                 dbdir = "tuto_duckdb.db",
                 config = list(memory_limit = "30G", threads = "4"))


customer <- tbl(con, "read_parquet('/tmp/tpch/customer.parquet')")
orders <- tbl(con, "read_parquet('/tmp/tpch/orders_parquet/**/*.parquet')")
lineitem <- tbl(con, "read_parquet('/tmp/tpch/lineitem.parquet')")

tic()
customer |>
  inner_join(orders, by = join_by(C_CUSTKEY == O_CUSTKEY)) |>
  inner_join(lineitem, by = join_by(O_ORDERKEY == L_ORDERKEY)) |>
  summarize(customer_nb = n_distinct(C_CUSTKEY),
            quantity = sum(L_QUANTITY),
            total_price = sum(O_TOTALPRICE)) |>
  collect()
toc()

tic()
dbExecute(con, "COPY (SELECT * FROM
  read_parquet('/tmp/tpch/orders_parquet/**/*.parquet') o,
  read_parquet('/tmp/tpch/customer.parquet') c,
  read_parquet('/tmp/tpch/lineitem.parquet') l
WHERE C_CUSTKEY = O_CUSTKEY AND O_ORDERKEY = L_ORDERKEY)
TO '/tmp/mondataset' (FORMAT PARQUET, PARTITION_BY (O_YEAR));")
toc()


tic()
dbExecute(con, "COPY (SELECT * FROM
  read_parquet('/home/nchuche/tpch/orders_parquet/**/*.parquet') o,
  read_parquet('/home/nchuche/tpch/customer.parquet') c,
  read_parquet('/home/nchuche/tpch/lineitem.parquet') l
WHERE C_CUSTKEY = O_CUSTKEY AND O_ORDERKEY = L_ORDERKEY)
TO 'mondataset2' (FORMAT PARQUET, PARTITION_BY (O_YEAR));")
toc()
