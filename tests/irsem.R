dataset <- "https://static.data.gouv.fr/resources/bureaux-de-vote-et-adresses-de-leurs-electeurs/20230626-135723/table-adresses-reu.parquet"

library(duckdb)
library(tidyverse)
library(glue)

cnx <- dbConnect(duckdb())

dbExecute(cnx, "LOAD httpfs")

dbSendQuery(cnx, glue("
  CREATE VIEW bureaux AS
    SELECT *
    FROM '{dataset}'"))



# available columns
dbGetQuery(cnx, "
  DESCRIBE bureaux")

# top communes by address number
dbGetQuery(cnx,"
  SELECT
    code_commune_ref,
    sum(nb_adresses) AS total_nb_adresses
  FROM bureaux
  GROUP BY code_commune_ref
  ORDER BY total_nb_adresses DESC
  LIMIT 10")
