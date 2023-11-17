library(arrow)
library(tidyverse)
library(tictoc)
library(lubridate)

file_path <- "/home/films/TPC-H V3.0.1/dbgen"
output_file_path <- "dbgen"

tables_col <- list(
  customer = c('CUSTKEY', 'NAME', 'ADDRESS', 'NATIONKEY', 'PHONE', 'ACCTBAL', 'MKTSEGMENT', 'COMMENT', 'TRUC'),
  orders = c('ORDERKEY', 'CUSTKEY', 'ORDERSTATUS', 'TOTALPRICE', 'ORDERDATE', 'ORDER_PRIORITY', 'CLERK', 'SHIP_PRIORITY', 'COMMENT', 'TRUC'),
  lineitem = c('ORDERKEY', 'PARTKEY', 'SUPPKEY', 'LINENUMBER', 'QUANTITY', 'EXTENDEDPRICE', 'DISCOUNT', 'TAX', 'RETURNFLAG', 'LINESTATUS', 'SHIPDATE', 'COMMITDATE', 'RECEIPTDATE', 'SHIPINSTRUCT', 'SHIPMODE', 'COMMENT', 'TRUC'),
  partsupp = c('PARTKEY', 'SUPPKEY', 'AVAILQTY', 'SUPPLYCOST', 'COMMENT', 'TRUC'),
  part = c('PARTKEY', 'NAME', 'MFGR', 'BRAND', 'TYPE', 'SIZE', 'CONTAINER', 'RETAILPRICE', 'COMMENT', 'TRUC'),
  supplier = c('SUPPKEY', 'NAME', 'ADDRESS', 'NATIONKEY', 'PHONE', 'ACCTBAL', 'COMMENT', 'TRUC'),
  nation = c('NATIONKEY', 'NAME', 'REGIONKEY', 'COMMENT', 'TRUC'),
  region = c('REGIONKEY', 'NAME', 'COMMENT', 'TRUC')
)

tables_prefix = list(
  customer = "C",
  orders = "O",
  lineitem = "L",
  partsupp = "PS",
  part = "P",
  supplier = "S",
  nation = "N",
  region = "R"
)

open_delim_dataset(file.path(file_path, "orders.tbl"), delim = "|", col_names = tables_col[['orders']]) %>%
  select(-c(TRUC)) %>%
  rename_with(~ paste0(tables_prefix[['orders']], "_", .x, recycle0 = TRUE)) %>%
  mutate(O_YEAR = year(O_ORDERDATE)) %>%
  group_by(O_YEAR) %>%
  write_dataset(file.path(output_file_path, "orders_parquet"), compression = "zstd", partitioning = 'O_YEAR')

open_delim_dataset(file.path(file_path, "lineitem.tbl"), delim = "|", col_names = tables_col[['lineitem']]) %>%
  select(-c(TRUC)) %>%
  rename_with(~ paste0(tables_prefix[['lineitem']], "_", .x, recycle0 = TRUE)) %>%
  write_dataset(file.path(output_file_path, "lineitem_parquet"), compression = "zstd")

read_delim_arrow(file.path(file_path, "customer.tbl"), delim = "|", col_names = tables_col[['customer']]) %>%
  select(-c(TRUC)) %>%
  rename_with(~ paste0(tables_prefix[['customer']], "_", .x, recycle0 = TRUE)) %>%
  write_parquet(file.path(output_file_path, "customer.parquet"), compression = "zstd")

open_delim_dataset(file.path(file_path, "nation.tbl"), delim = "|", col_names = tables_col[['nation']]) %>%
  select(-c(TRUC)) %>%
  collect() %>%
  write_delim(file.path(output_file_path, "nation.csv"), delim = ";")
