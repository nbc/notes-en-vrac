library(tidyverse)

tb <- tibble(col = c("Une chaine de caractère. avec de la ponctuation !"))

tb |> mutate(new = str_replace_all(col, "[:punct:]", ""))
tb |> mutate(new = str_replace_all(col, "[[:punct:]]", ""))

conn <- dbConnect(duckdb())

duckdb_register(conn, "tb", tb, overwrite = TRUE)
tbl(conn, "tb") |> mutate(new = str_replace_all(col, "[:punct:]", ""))

tbl(conn, "tb") |> mutate(new = str_replace_all(col, "[[:punct:]]", ""))

tbl(conn, "tb") |> mutate(new = str_replace_all(col, "[[:punct:]]", "")) |> dbplyr::sql_render()
