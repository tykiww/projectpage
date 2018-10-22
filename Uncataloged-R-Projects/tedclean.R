ted <- read.csv('ted.csv', stringsAsFactors=FALSE) %>% as.tibble

a <- ted['tags'] %>% # extract the tags column
  split(seq(nrow(ted))) %>%
  unlist %>% unname

# clean the letters.
b <- a %>%
  sapply(function(x) strsplit(gsub("[^[:alnum:|, ]", "", x), ",")[[1]]) %>% 
  unlist
# create the tag names.
tag_names <- unique(b) %>% trimws %>% sort


# Go through the tag_names and for each add a column to the ted dataset
# and make it true or false based on whether string is present in tag list
new_ted <- ted
rm(ted)


# create row of tags and make clean it up.

new_ted$tags <- sapply(a,function(x) paste(strsplit(gsub("[^[:alnum:] ]", ",", x), ",")[[1]], collapse=','))





for (i in tag_names) {
  new_col <- NULL
  for (row in 1:nrow(new_ted)) {
    if (length(grep(i, new_ted[row, 'tags'])) != 0) { # if we can grep the tags, put true.
      new_col[row] <- TRUE
    } else {
      new_col[row] <- FALSE
    }
  }
  new_ted <- cbind(new_ted, new_col) # add the columns
  colnames(new_ted)[length(colnames(new_ted))] <- paste0("TAG_", i)
}

a_done <- new_ted
rm(new_ted)

# b. Using the ratings column, create a new column for each rating category (14 in total). 
# The value will be the count for the associated category for each row. 
# For example, if the value is [{'id': 7, 'name': 'Funny', 'count': 19645}, {'id': 1, 'name': 'Beautiful', 'count': 4573}]. 
# Then the RATINGS_Funny column will be 19645 and RATINGS_Beautiful column will be 4573.
# c. Using LASSO, fit a model using comments, duration, number of speakers (num_speaker), the tag data (TAGS_xxx), and the ratings data (RATINGS_xxx). The TAG_ columns are true and false based on if the


# Splitting up ratings
rating_names <- c("Inspiring", "Persuasive", "Courageous", "Fascinating", "Informative",
                  "Ingenious", "Unconvincing", "Obnoxious", "Longwinded", "Jaw-dropping",
                  "Confusing", "Funny", "Beautiful", "OK")

for (rat_name in rating_names) {
  new_col <- rep(FALSE, nrow(a_done))
  for (row in 1:nrow(a_done)) {
    q <- str_locate(a_done[row, 'ratings'], rat_name)[2] + 13
    r <- substr(a_done[row, 'ratings'], q, nchar(a_done[row, 'ratings']))
    s <- str_locate(r, '\\}')[2]
    
    new_col[row] <- as.integer(substr(r, 1, s - 1))
  }
  a_done <- cbind(a_done, new_col)
  colnames(a_done)[length(colnames(a_done))] <- paste0("RATINGS_", rat_name)
}

b_done <- a_done
                       
                       
                       nn <- c("description", "event", "film_date", "languages", 
        "main_speaker", "name", "published_date",
        "ratings", "related_talks", "speaker_occupation", "tags",
        "title", "url")
b_done[,!(colnames(b_done)%in%nn)] -> lasso_part

nn <- c("description", "event", "film_date", "languages", 
        "main_speaker", "name", "published_date",
        "ratings", "related_talks", "speaker_occupation", "tags",
        "title", "url")
b_done[,!(colnames(b_done)%in%nn)] -> lasso_part


