library(arrow)
library(tidyverse)
library(duckdb)
library(tictoc)
library(dplyr)
library(glue)

file_path <- "dbgen"

con <- dbConnect(duckdb(), dbdir = "ma_base.db", config = list(memory_limit = "10G", "temp_directory" = "tmp"))

customer <- open_dataset(file.path(file_path, "customer_parquet")) %>% to_duckdb(con)
orders <- open_dataset(file.path(file_path, "orders_parquet")) %>% to_duckdb(con)
lineitem <- open_dataset(file.path(file_path, "lineitem_parquet")) %>% to_duckdb(con)
partsupp <-  open_dataset(file.path(file_path, "partsupp_parquet")) %>% to_duckdb(con)
part <- open_dataset(file.path(file_path, "part_parquet")) %>% to_duckdb(con)
supplier <- open_dataset(file.path(file_path, "supplier_parquet")) %>% to_duckdb(con)
nation <- open_dataset(file.path(file_path, "nation_parquet")) %>% to_duckdb(con)
region <- open_dataset(file.path(file_path, "region_parquet")) %>% to_duckdb(con)

tic()
customer %>%
  right_join(orders, by = join_by(C_CUSTKEY == O_CUSTKEY)) %>%
  right_join(lineitem, by = join_by(O_ORDERKEY == L_ORDERKEY)) %>%
  right_join(partsupp, by = join_by(L_PARTKEY == PS_PARTKEY, L_SUPPKEY == PS_SUPPKEY)) %>%
  right_join(part, by = join_by(L_PARTKEY == P_PARTKEY)) %>%
  right_join(supplier, by = join_by(L_SUPPKEY == S_SUPPKEY)) %>%
  group_by(S_NAME) %>%
  summarize(customer_nb = n_distinct(C_CUSTKEY), quantity = sum(L_QUANTITY), total_price = sum(O_TOTALPRICE)) %>%
  collect()
toc()

tic()
orders %>%
right_join(lineitem, by = join_by(O_ORDERKEY == L_ORDERKEY)) %>%
  group_by(L_PARTKEY) %>%
  summarize(customer = n_distinct(O_CUSTKEY), sum = sum(L_QUANTITY), orders = n_distinct(O_ORDERKEY)) %>%
  collect()
toc()


library(duckdb)
library(DBI)

con <- dbConnect(duckdb())

dbExecute(con, "LOAD tpch;")
dbExecute(con, "CALL dbgen(sf = 1)")

dbExecute(con, "COPY lineitem TO 'lineitem.parquet' (FORMAT PARQUET)")
dbExecute(con, "COPY (SELECT *, YEAR(O_ORDERDATE) AS O_YEAR FROM orders) TO 'orders_parquet' (FORMAT PARQUET, PARTITION_BY (O_YEAR))")
dbExecute(con, "COPY customer TO 'customer.parquet' (FORMAT PARQUET)")
