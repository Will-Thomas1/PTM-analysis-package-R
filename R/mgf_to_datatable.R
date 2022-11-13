variables_to_set_to_NULL <- c("frg_int", "frg_mz", "is_ion", "line_num", "rawscans", "rtinseconds_end",
                              "rtinseconds_start", "spec_num", "stri_join", "tag", "title", "title_rt_start", "title_scan_start",
                              "PEPMASS", "CHARGE", "SCANS", "RTINSECONDS", "RAWSCANS", "TITLE")

for (x in variables_to_set_to_NULL){ #Set these variables to NULL so they don't appear as a WARNING.

  assign(x, NULL)

}

utils::globalVariables(c(".N", "J", "V1")) #Again, avoid warnings.

#' Translate .mgf data into a datatable format.
#'
#' This function converts .mgf files to a tabletable that can be manipulated in R.
#'
#' Upon running this function a file explorer window will open, allowing the user to select the .mgf files of choice.
#' @return The .mgf file as a datatable.
#' @importFrom rlang .data
#' @importFrom data.table ':='
#' @export

mgf_to_datatable <- function(){

  paths <- utils::choose.files()

  start_time <- Sys.time()
  data.table::setDTthreads(0L) #Use all available threads

  tryCatch(paths <- normalizePath(paths), warning = function(w)warning(w), error = function(e)warning(e))

  print(paste0('Start reading at ', round(as.numeric(Sys.time() - start_time), 1)))

  mgf_dt <- data.table::fread(paths, stringsAsFactors = F, header = F, colClasses = 'character', sep = '\n',
                  blank.lines.skip = T,
                  verbose = T, showProgress = T, strip.white = T) # slow; don't know a faster way to read

  print(paste0('Finished reading at ', round(as.numeric(Sys.time() - start_time), 1)))

  line_ct <- mgf_dt[, .N]
  mgf_dt[, line_num := 1:line_ct]

  # -------- substr is faster than both str_sub and stri_sub
  mgf_dt[, is_ion := substr(V1, 1, 1) %in% as.character(0:9)] # According to Matrix Science website,
  # any line starting with numbers describes an ion,
  # any line starting with words describes spectrum or dataset

  print(paste0('Ions detected at ', round(as.numeric(Sys.time() - start_time), 1)))

  data.table::setkey(mgf_dt, is_ion)
  mgf_tags_dt <- data.table::setkey(mgf_dt[J(F), .(line_num, V1)], V1)
  mgf_dt <- data.table::setkey(mgf_dt[J(T), list(line_num, V1)], line_num)

  begins <- sort(mgf_tags_dt['BEGIN IONS', line_num])
  # ------ this is >5 times faster than begins <- sort(mgf_dt[V1 == 'BEGIN IONS', line_num]) because > 95% of mgf is ions, not tags

  ends <- sort(mgf_tags_dt['END IONS', line_num])

  print(paste0('Begins ends detected at ', round(as.numeric(Sys.time() - start_time), 1)))

  if (length(begins) == 0) {
    warning('No spectra found in your file (based on BEGIN IONS TAG).')
    return(NULL)
  }

  if (length(begins) != length(ends)) {
    warning('Problem with tags: number of BEGIN IONS tags is not the same as END IONS tags.')
    return(NULL)
  }

  lengths <- ends - begins + 1

  if (any(lengths <= 1)) {
    warning('Problem with tags: some BEGIN IONS and END IONS tags have wrong order.')
    return(NULL)
  }

  spec_ct <- length(begins)

  spec_index <- data.table::setkey(merge(data.table::rbindlist(lapply(1L:spec_ct, function(spec){data.table::data.table(spec_num = spec, line_num = begins[spec]:ends[spec])})),
                             data.table(line_num = 1L:line_ct), all = TRUE), line_num)


  data.table::setkey(mgf_tags_dt, line_num)

  mgf_dt <- data.table::setkey(mgf_dt[spec_index, .(spec_num, V1), nomatch = 0], spec_num)
  mgf_tags_dt <- data.table::setkey(merge(mgf_tags_dt, spec_index, all = F)[, tag := sapply(stringi::stri_split(V1, fixed = '=',
                                                                                           n = 2), '[', 1)], tag)

  rm(spec_index)

  print(paste0('Tags detected at ', round(as.numeric(Sys.time() - start_time), 1)))

  file_tags <- mgf_tags_dt[is.na(spec_num)][, .(line_num, tag)]

  #if (mode == 'FC') {
  mgf_tags_dt <-
    data.table::dcast.data.table(mgf_tags_dt[!J(c('BEGIN IONS', 'END IONS'))][!is.na(spec_num)], spec_num ~ tag,
                     value.var = 'V1')
  mgf_tags_dt[, `:=`(prec_mz = as.numeric(stringi::stri_match_first_regex(PEPMASS, '^PEPMASS=([[:digit:]]+\\.?[[:digit:]]*) ([[:digit:]]+\\.?[[:digit:]]*[e]?[+]?[[:digit:]]*)(.*)$')[,2]),
                     prec_int = as.numeric(stringi::stri_match_first_regex(PEPMASS, '^PEPMASS=([[:digit:]]+\\.?[[:digit:]]*) ([[:digit:]]+\\.?[[:digit:]]*[e]?[+]?[[:digit:]]*)(.*)$')[,3]))]
  mgf_tags_dt[, PEPMASS := NULL]

  mgf_tags_dt[, `:=`(charge = as.integer(apply(stringi::stri_match_first_regex(CHARGE, '^CHARGE=([[:digit:]]+)([+-]?)$')[, 3:2],
                                               1, stringi::stri_join, collapse = '')))]
  mgf_tags_dt[, CHARGE := NULL]

  mgf_tags_dt[!grepl('-', SCANS), `:=`(scans = list(sapply(strsplit(sub('SCANS=', '', SCANS), split = ',', fixed = TRUE), as.integer))), spec_num]
  mgf_tags_dt[grepl('-', SCANS), `:=`(scans = list(Reduce(seq, sapply(strsplit(sub('SCANS=', '', SCANS), split = '-', fixed = TRUE)[[1]], as.integer, USE.NAMES = FALSE)))), spec_num]
  # mgf_tags_dt[, n_scans := length(scans[[1]]), spec_num]
  # mgf_tags_dt[, first_scan := min(scans[[1]]), spec_num]
  # mgf_tags_dt[, last_scan := min(scans[[1]]), spec_num]
  mgf_tags_dt[, SCANS := NULL]

  mgf_tags_dt[, rtinseconds_start := as.numeric(stringi::stri_match_first_regex(RTINSECONDS, '^RTINSECONDS=([[:digit:]]+\\.?[[:digit:]]*)(-?)([[:digit:]]+\\.?[[:digit:]]*)$')[, 2L])]
  mgf_tags_dt[!grepl('-', RTINSECONDS), rtinseconds_end := rtinseconds_start]
  mgf_tags_dt[grepl('-', RTINSECONDS), rtinseconds_end := as.numeric(stringi::stri_match_first_regex(RTINSECONDS, '^RTINSECONDS=([[:digit:]]+\\.?[[:digit:]]*)(-?)([[:digit:]]+\\.?[[:digit:]]*)$')[, 4L])]
  # mgf_tags_dt[, duration := rtinseconds_end - rtinseconds_start]
  mgf_tags_dt[, RTINSECONDS := NULL]

  mgf_tags_dt[, rawscans := sub('RAWSCANS=', '', RAWSCANS)]
  mgf_tags_dt[, RAWSCANS := NULL]

  mgf_tags_dt[, title := stringi::stri_match_first_regex(TITLE, '^TITLE=(.*)$')[, 2]]
  mgf_tags_dt[, TITLE := NULL]

  mgf_tags_dt[!grepl('Sum of', title), c('title_n', 'title_scan_start', 'title_rt_start', 'title_paths') := {
    tmp <- stringi::stri_match_first_regex(title, pattern = '^([[:digit:]]+): Scan ([[:digit:]]+) \\(rt=([[:digit:]]+\\.?[[:digit:]]*)\\) \\[(.*)\\]$')
    .(as.integer(tmp[, 2]), as.integer(tmp[, 3]), as.numeric(tmp[, 4]), tmp[, 5])
  }, spec_num]

  mgf_tags_dt[!grepl('Sum of', title), `:=`(title_n_scans = 1L, title_scan_end = title_scan_start, title_rt_end = title_rt_start)]

  mgf_tags_dt[grepl('Sum of', title), c('title_n', 'title_n_scans', 'title_scan_start', 'title_rt_start',  'title_scan_end', 'title_rt_end', 'title_paths') := {
    tmp <- stringi::stri_match_first_regex(title, pattern = '^([[:digit:]]+): Sum of ([[:digit:]]+) scans\\. Range ([[:digit:]]+) \\(rt=([[:digit:]]+\\.?[[:digit:]]*)\\) to ([[:digit:]]+) \\(rt=([[:digit:]]+\\.?[[:digit:]]*)\\) \\[(.*)\\]$')
    .(as.integer(tmp[, 2L]), as.integer(tmp[, 3L]), as.integer(tmp[, 4L]), as.numeric(tmp[, 5L]), as.integer(tmp[, 6L]), as.numeric(tmp[, 7L]), tmp[, 8L])
  }, spec_num]


  ok <- sapply(colnames(mgf_tags_dt), function(x)mgf_tags_dt[is.na(get(x)), .N]) == 0L
  if (any(!ok)) {
    message(paste0('Failed to meaningfully parse some tags, columns with NA: ', colnames(mgf_tags_dt)[!ok]))
  }
  #}

  print(paste0('Tags parsed at ', round(as.numeric(Sys.time() - start_time), 1)))

  print(paste0('Locuses parsed at ', round(as.numeric(Sys.time() - start_time), 1)))
  # ------
  # if (mode == 'FC') {
  res <- mgf_dt[, c('frg_mz', 'frg_int', 'V1') :=
                  {
                    split <- stringi::stri_split_fixed(V1, pattern = '\t', n = 2, simplify = T);
                    .(as.numeric(split[, 1]), as.numeric(split[, 2]), NULL)
                  }][, {order <- order(frg_mz); .(frg_mz = list(frg_mz[order]), frg_int = list(frg_int[order]))}, spec_num][mgf_tags_dt]

  # slow, but stringi::stri_split_fixed and n = 3 is 5 time faster then base strsplit; this is the slowest part (45% of time)

  print(paste0('Ions detected at ', round(as.numeric(Sys.time() - start_time), 1)))

  data.table::setkey(res, 'spec_num')
  attr(res, 'file_tags') <- file_tags

  res
}



####Helper functions####


  #var_name <- basename(paths[i]) %>%
    #stringi::stri_replace_all_regex(., ".mgf$", "") %>%
    #make.names(.) #makes sure the file name works as a var name.

  #pos <- 1 #Avoid CMD check note.

  #assign(var_name, res, envir = as.environment(pos))



