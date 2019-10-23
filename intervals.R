# Numerical interval manupulation and comparison


# See also:
# 
# https://github.com/edzer/intervals
# https://www.rdocumentation.org/packages/IntervalSurgeon/versions/1.0
# 
# The first one looks fine.


# Creating intervals ------------------------------------------------------

# Create an interval [from; to] with optional left/right closing

interval <- function(from, to, close=c("no", "from", "to")) {
  # Argument checks
  stopifnot(is.numeric(from) && length(from) == 1)
  stopifnot(is.numeric(to) && length(to) == 1)
  closing <- match.arg(close, several.ok=TRUE)
  stopifnot( !("no" %in% closing) | (length(closing) == 1) )
  
  v <- c(from, to)
  names(v) <- c(
    if("from" %in% closing) "closed" else "open",
    if("to" %in% closing) "closed" else "open"
  )
  structure(v, class="interval")
}



# Syntactic sugar

"%()%" <- function(x, y) interval(x, y, close="no")
"%[]%" <- function(x, y) interval(x, y, close=c("from", "to"))
"%[)%" <- function(x, y) interval(x, y, close="from")
"%(]%" <- function(x, y) interval(x, y, close="to")




# Convert to interval
as.interval <- function(x, close=c("from", "to")) {
  interval(min(x), max(x), close=close)
}



# Accessor functions ------------------------------------------------------

left_closed <- function(x) names(x)[1] == "closed"

"left_closed<-" <- function(x, value) {
  names(x)[1] <- if(value) "closed" else "open"
  x
}

right_closed <- function(x) names(x)[2] == "closed"

"right_closed<-" <- function(x, value) {
  names(x)[2] <- if(value) "closed" else "open"
  x
}

closed <- function(x) left_closed(x) && right_closed(x)



# Printing intervals ------------------------------------------------------

print.interval <- function(x, ...) {
  cat("<interval>\n")
  cat(
    if(left_closed(x)) "[" else "(",
    x[1],
    "; ",
    x[2],
    if(right_closed(x)) "]" else ")",
    "\n",
    sep = ""
  )
}








# Do two intervals overlap? ------------------------------------------------

# Test if interval `x` overlaps with interval `y`
# 
# @param x,y interval objects
#

overlap <- function(x, y) {
  # x - y
  c1 <- do.call(
    if(right_closed(x) && left_closed(y)) "<" else "<=",
    list(e1=x[2], e2=y[1])
  )
  # y - x
  c2 <- do.call(
    if(right_closed(y) && left_closed(x) ) "<" else "<=",
    list(e1=y[2], e2=x[1])
  )
  !(c1 || c1)
  # !(x[2] < y[1] | x[1] > y[2])
}


stopifnot(
  # Overlap
  overlap( 1 %()% 2, 0.5 %()% 3),
  overlap(0.5 %()% 3,  1 %()% 2),
  overlap( 1 %(]% 2, 2 %[)% 3),
  overlap( 1 %()% 2, 0 %()% 3),
  overlap( 1 %[)% 2, 1 %[)% 3),
  # No overlap
  !overlap( 1 %()% 2, 2 %[)% 3),
  !overlap( 1 %(]% 2, 2 %()% 3),
  !overlap( 1 %()% 2, 2 %()% 3)
)





# The overlap interval ---------------------------------------------------

# If the two intervals overlap return the overlap as an interval. E.g. given [a;
# b] and [c; d] where a < c, b > c, d > b the overlap interval will be [b; c].
# Return NA if intervals do not overlap.

overlap_interval <- function(x, y) {
  if(!overlap(x, y)) return(as.numeric(NA))
  
  
}
