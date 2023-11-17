library(arrow)
library(tidyverse)

ar1 <- tibble(
  col1 = c(1,2,3,4)
) |> as_arrow_table()

ar2 <- tibble(
  col1 = c(5,6,7,8)
) |> as_arrow_table()

ar <- c(ar1, ar2)

ar |>
  summarize(mean = mean(col1))
