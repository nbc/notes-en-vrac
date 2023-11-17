library(tidyverse)
library(duckdb)
library(arrow)

tb = tibble(
  adresse = c('1, RUE DE BERCY, 92500 Paris', '3 rue de bagnolet. 93000 Montreuil'),
  texte_avec_annee = c('fichier_1993.csv', 'nom_de_fichier_2003.csv'),
  date = ymd(c("2023-09-01"), "2019-03-05")
) |> write_parquet("test.parquet")
tb


con <- dbConnect(duckdb())

duckdb_register(con, "mon_tb", tb)

tbl(con, "mon_tb")

request <- tbl(con, "mon_tb") |>
  mutate(
    # [^a-z0-9 ] indique tous les caractères SAUF ceux cités (et ceux entre)
    # le 'g' final indique que le replacement doit être global
    adresse = regexp_replace(lower(adresse), '[^a-z0-9 ]+', '', 'g'),
    annee_extraite = as.integer(regexp_extract(texte_avec_annee, '([0-9]+)')),
    premier_janvier_annee_extraite = make_date(annee_extraite, 1L, 1L),
    premier_du_mois_date = date_trunc('month', date)
  )

request |> dbplyr::sql_render()
request |> collect()
