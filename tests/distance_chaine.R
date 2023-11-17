library(duckdb)
library(readr)
library(dplyr)
library(arrow)
library(tictoc)

con <- dbConnect(duckdb())

dbExecute(con, "COPY (SELECT * FROM read_csv_auto('/home/nc/Downloads/french-address-matching_SSPCloud/DonneesCompletes.csv', ignore_errors = true, quote = '\"')) TO 'french-address.parquet'")

dbGetQuery(con, "SELECT * FROM read_csv_auto('ici4.csv', sep = ',', ignore_errors = true) LIMIT 10")

read_delim("ici.csv", delim =";") |>
  write_parquet("ici.parquet")


tbl(con, "read_parquet('ici.parquet')") |>
  select(commune) |>
  mutate(commune = tolower(commune)) |>
  group_by(commune) |>
  summarize(n = n()) |>
  to_arrow() |>
  write_parquet("communes.parquet")

dbExecute(con, "CREATE OR REPLACE VIEW communes AS SELECT * FROM 'communes.parquet' LIMIT 10000")

tic()
dbGetQuery(con, "SELECT ici1.commune, ici2.commune FROM communes AS ici1, communes AS ici2 WHERE ici1.commune <> ici2.commune AND (levenshtein(LOWER(ici1.commune), LOWER(ici2.commune))) / LEN < 3")
toc()
