con <- dbConnect(duckdb())

tb <- tibble(col = c("1", "2", "3"))

dbWriteTable(con, "tb", tb)

tbl(con, "tb")

tb %>%
  filter(col == 1)

tb |>
  as_arrow_table() |>
  filter(col == 1) |>
  collect()

tb <- tibble(col = c(TRUE, TRUE, TRUE))

dbWriteTable(con, "tb", tb, overwrite = TRUE)
tbl(con, "tb") |>
  summarise(sum = sum(col)) |>
  collect()
