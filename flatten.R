# Flatten JSON data to RDBM


library(dplyr)
library(tidyr)
library(mongolite)
library(RPostgreSQL)

# Input in MongoDB
mcon <- mongo(collection="letters", db="listy_portugalskie", url="mongodb://localhost")
mcon$count()

# Output to Postgres
sqlcon <- "dbConnect()"   # TODO connect to database



# Documents ---------------------------------------------------------------

docs <- mcon$find(
  fields='{
    "doc_id": true,
    "doc_type": true,
    "date": true,
    "text": true,
    "_id": false
  }'
) %>%
  as_tibble()

dbWriteTable(sqlcon, "docs", docs)




# Sender ------------------------------------------------------------------

ndf <- new.env()
mcon$find(
  fields='{
    "doc_id": true,
    "sender.org": true, 
    "sender.aff": true, 
    "sender.names": true, 
    "sender.roles": true, 
    "_id": false
  }',
  handler = function(df) {
    idx <- as.character(length(ndf) + 1)
    ndf[[idx]] <- transmute(
      df, 
      doc_id,
      sender_org = sender$org,
      sender_aff = sender$aff,
      sender_names = sender$names,
      sender_roles = sender$roles
    )
  },
  pagesize = 5000
)

sender <- ndf %>%
  as.list() %>%
  bind_rows() %>%
  as_tibble() %>%
  gather(.var, .val, -doc_id) %>%
  unnest() %>%
  group_by(doc_id, .var) %>%
  mutate(
    pos = seq(1, length(.val))
  ) %>%
  ungroup() %>%
  separate(.var, into=c("f1", "f2")) %>%
  select(doc_id, field=f2, pos=pos, value=.val)

dbWriteTable(sqlcon, "sender", sender)



# Recipient ---------------------------------------------------------------

ndf <- new.env()
mcon$find(
  fields='{
    "doc_id": true,
    "recipient.org": true, 
    "recipient.aff": true, 
    "recipient.names": true, 
    "recipient.roles": true, 
    "_id": false
  }',
  handler = function(df) {
    idx <- as.character(length(ndf) + 1)
    ndf[[idx]] <- transmute(
      df, 
      doc_id,
      recipient_org = recipient$org,
      recipient_aff = recipient$aff,
      recipient_names = recipient$names,
      recipient_roles = recipient$roles
    )
  },
  pagesize = 5000
)

recipient <- ndf %>%
  as.list() %>%
  bind_rows() %>%
  as_tibble() %>%
  gather(.var, .val, -doc_id) %>%
  unnest() %>%
  group_by(doc_id, .var) %>%
  mutate(
    pos = seq(1, length(.val))
  ) %>%
  ungroup() %>%
  separate(.var, into=c("f1", "f2")) %>%
  select(doc_id, field=f2, pos=pos, value=.val)

dbWriteTable(sqlcon, "recipient", recipient)





# Other -------------------------------------------------------------------


others <- mcon$find(
  fields='{
    "doc_id": true,
    "others": true,
    "_id": false
  }'
) %>%
  as_tibble() %>%
  unnest() %>%
  group_by(doc_id) %>%
  mutate(
    pos = seq(1, length(others))
  ) %>%
  ungroup()

dbWriteTable(sqlcon, "others", others)
