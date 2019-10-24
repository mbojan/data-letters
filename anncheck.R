library(tidyverse)
















# Parse annotated document ------------------------------------------------

fname <- "train_poi_data_maxqda/370_3.txt"
l <- readLines(fname)
d <- enframe(l[-1], name = "id") %>%
  mutate(
    value = gsub("^\\(|\\)$", "", value)
  ) %>%
  separate(
    value,
    sep=";",
    into = c("text", "from", "to", "category")
  ) %>%
  mutate_at(c("from", "to"), as.integer) %>%
  mutate(
    category = trimws(category)
  )


# Check for duplicated annotations ----------------------------------------

table(duplicated(d[,-1]))



# Check for overlaps ------------------------------------------------------

# Testing Overlap()

if(FALSE) {
  ranges <- list(
    a = c(2, 7),
    b = c(1, 3),
    c = c(5, 8),
    d = c(4, 6)
  ) %>%
    enframe()
  
  k <- crossing(
    r1 = ranges$name,
    r2 = ranges$name
  ) %>%
    filter(r1 != r2) %>%
    left_join(ranges, by=c(r1="name")) %>%
    left_join(ranges, by=c(r2="name")) %>%
    mutate(
      text.x = map_chr(value.x, ~ paste0("(", .x[1], ", ", .x[2], ")")),
      text.y = map_chr(value.y, ~ paste0("(", .x[1], ", ", .x[2], ")")),
      length_x = map_dbl(value.x, ~ .x[2] - .x[1] + 1),
      length_y = map_dbl(value.y, ~ .x[2] - .x[1] + 1),
      shortest_len = pmin(length_x, length_y),
      overlap = map2_lgl(value.x, value.y, ~ ..1 %overlaps% ..2),
      overlap_fun = map2_dbl(value.x, value.y, ~ Overlap(..1, ..2)),
      interval = map2_dbl(value.x, value.y, ~ Interval(..1, ..2)),
      x_contains_y = overlap & overlap_fun == length_y
    ) 
  
  k %>%
    count(overlap, overlap_fun, interval)
}



library(intervals)

ints <- d %>%
  select(from, to) %>%
  data.matrix() %>%
  Intervals(closed=c(TRUE, TRUE), type="Z")
interval_overlap(ints, ints)

substring(l[1], d$from, d$to)
