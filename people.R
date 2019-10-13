library(poidata)
library(dplyr)

# People:
# - Unique senders
# - Unique recipients
# - Other persons:
#     + sender lookup
#     + recipient lookup
#     + regexp matching?

r <- poidata::recipients() %>%
  distinct(value)

s <- poidata::senders() %>%
  distinct(value)

ppl <- bind_rows(r, s) %>%
  distinct(value) %>%
  mutate(
    in_sender = value %in% s$value,
    in_recipient = value %in% r$value
  ) %>%
  arrange(value)
