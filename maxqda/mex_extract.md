Extracting data from MEX files
================
Michał Bojanowski
2018-01-10

-   [Read data](#read-data)
-   [Extract](#extract)
-   [Bad file names](#bad-file-names)
-   [Save as CSV](#save-as-csv)

Read data
=========

Directories (unzipped files from Agata)

``` r
dirs <- c(
  "Documents 100-300 (without Portuguese letters)",
  "WSZYSTKIE"
)
```

File name database

``` r
files <- 
lapply(
  dirs,
  function(d) {
    data_frame(
      mex_dir=d, 
      mex_file=list.files(d)
      )
  }
) %>%
  bind_rows() %>%
  mutate(
    mex_path = file.path(mex_dir, mex_file)
  )
```

Extract
=======

``` r
train <-
files %>%
  mutate(
    data = lapply(files$mex_path, extract_mex_codings)
  ) %>%
  unnest(data) 
```

    ## Warning in FUN(X[[i]], ...): number of preview strings 63 chars long = 5

    ## Warning in FUN(X[[i]], ...): number of preview strings 63 chars long = 4

    ## Warning in FUN(X[[i]], ...): number of preview strings 63 chars long = 1

    ## Warning in FUN(X[[i]], ...): number of preview strings 63 chars long = 1

    ## Warning in FUN(X[[i]], ...): number of preview strings 63 chars long = 2

    ## Warning in FUN(X[[i]], ...): number of preview strings 63 chars long = 1

    ## Warning in FUN(X[[i]], ...): number of preview strings 63 chars long = 3

    ## Warning in FUN(X[[i]], ...): number of preview strings 63 chars long = 5

    ## Warning in FUN(X[[i]], ...): number of preview strings 63 chars long = 3

    ## Warning in FUN(X[[i]], ...): number of preview strings 63 chars long = 4

    ## Warning in FUN(X[[i]], ...): number of preview strings 63 chars long = 3

    ## Warning in FUN(X[[i]], ...): number of preview strings 63 chars long = 1

    ## Warning in FUN(X[[i]], ...): number of preview strings 63 chars long = 1

    ## Warning in FUN(X[[i]], ...): number of preview strings 63 chars long = 4

    ## Warning in FUN(X[[i]], ...): number of preview strings 63 chars long = 6

    ## Warning in FUN(X[[i]], ...): number of preview strings 63 chars long = 1

    ## Warning in FUN(X[[i]], ...): number of preview strings 63 chars long = 63

And thus we have

``` r
glimpse(train)
```

    ## Observations: 31,627
    ## Variables: 12
    ## $ mex_dir        <chr> "Documents 100-300 (without Portuguese letters)...
    ## $ mex_file       <chr> "100-300.mex", "100-300.mex", "100-300.mex", "1...
    ## $ mex_path       <chr> "Documents 100-300 (without Portuguese letters)...
    ## $ ID             <int> 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, ...
    ## $ TextID         <int> 12, 12, 12, 12, 12, 12, 12, 12, 1, 1, 1, 1, 1, ...
    ## $ WordID         <int> 3, 4, 4, 5, 7, 1, 1, 1, 7, 5, 5, 5, 4, 4, 4, 3,...
    ## $ Preview        <chr> "REQUERIMENTO", "Alexandre Aires de Figueiredo"...
    ## $ start          <int> 32, 47, 84, 188, 13, 80, 148, 165, 8, 28, 61, 2...
    ## $ end            <int> 45, 77, 95, 211, 31, 84, 161, 174, 28, 38, 66, ...
    ## $ file_name      <chr> "113_1479", "113_1479", "113_1479", "113_1479",...
    ## $ tag            <chr> "TYPE", "PERSON", "PERSON", "LOCALIZATION", "DA...
    ## $ preview_length <int> 12, 29, 10, 23, 18, 3, 12, 9, 19, 9, 5, 14, 32,...

Bad file names
==============

Catching MEX files that do not have proper file names. These popped-up because some of the coders did not import the source files, but pasted their content directly into MAXQDA. In consequence, we lost the connection between file name and its content.

``` r
bf <-
train %>%
  extract(
    file_name,
    into = c("bf_word", "bf_id"),
    regex = "^([A-Za-z]+) \\(([0-9]+)\\)",
    remove = FALSE
  ) %>%
  mutate(
    bf_is = !is.na(bf_word) | is.na(file_name),
    bf_id = as.numeric(bf_id)
  )
```

Number of text fragments that do or do not have proper file name, per MEX file. "Bad" fragments cannot be (easily) matched with full text.

``` r
z <-
bf %>%
  mutate(
    ok = ifelse(bf_is, "bad", "good")
  )

z %>%
  count(mex_file, ok) %>%
  spread(ok, n) %>%
  knitr::kable()
```

| mex\_file                           |  bad|   good|
|:------------------------------------|----:|------:|
| 100-300.mex                         |    -|   1353|
| 10 - wszystko.mex                   |  559|      -|
| 11 - wszystko exchange.mex          |  503|      -|
| 12 - wszystko - Esther exchange.mex |    -|    519|
| 13 od 1 do 20.mex                   |  204|      -|
| 14 - od 1 do 10 exchange.mex        |   88|      -|
| 15 - wszystko.mex                   |  445|      -|
| 16 - od 1 do 17 exchange.mex        |  178|      -|
| 18 - od 1 do 18.mex                 |  153|      9|
| 19 - zrobiony do 14.mex             |  119|      -|
| 1 - wszystko.mex                    |  518|     12|
| 20 - wszystko exchange.mex          |  569|      -|
| 24 wszystko.mex                     |    -|    482|
| 25 - wszystko.mex                   |  552|      -|
| 26 - WSZYSTKO exchamhe.mex          |    -|    518|
| 2 - wszystko exchane.mex            |  531|      -|
| 300-400 EXCHANGE FILE.mex           |    -|    732|
| 3 - wszystko.mex                    |  497|      -|
| 4100-4229.mex                       |    -|    855|
| 4 caИoШЖ.mex                        |  499|      8|
| 5 caИoШЖ - exchange file.mex        |  523|      -|
| 7 od 1 do 18 exchange.mex           |  109|      -|
| 8 - CAЭOЧC.mex                      |  224|    214|
| 9 - wszystko.mex                    |  469|      -|
| Aline - wszystko.mex                |    -|    365|
| MAGDA 1100-1200.mex                 |    -|    378|
| Rafael - wszystko.mex               |    -|   1079|
| WSZYSTKO 1600 - 4000.mex            |    7|  18356|

``` r
z %>%
  count(ok) %>%
  knitr::kable()
```

| ok   |      n|
|:-----|------:|
| bad  |   6747|
| good |  24880|

Save as CSV
===========

``` r
readr::write_csv(train, "training_data.csv")
```
