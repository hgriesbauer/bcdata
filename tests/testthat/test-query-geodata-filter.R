context("testing ability of filter methods to narrow a wfs query")
library(sf, quietly = TRUE)

test_that("bcdc_query_geodata accepts R expressions to refine data call",{
  skip_if_net_down()
  one_well <- bcdc_query_geodata("ground-water-wells") %>%
    filter(OBSERVATION_WELL_NUMBER == 108) %>%
    collect()
  expect_is(one_well, "sf")
  expect_equal(attr(one_well, "sf_column"), "geometry")
  expect_equal(nrow(one_well), 1)
})

test_that("bcdc_query_geodata accepts R expressions to refine data call",{
  skip_if_net_down()
  one_well <- bcdc_query_geodata("ground-water-wells") %>%
    filter(OBSERVATION_WELL_NUMBER == 108) %>%
    collect()
  expect_is(one_well, "sf")
  expect_equal(attr(one_well, "sf_column"), "geometry")
  expect_equal(nrow(one_well), 1)
})

test_that("operators work with different remote geom col names",{
  skip_if_net_down()

  ## LOCAL
  crd <- bcdc_query_geodata("regional-districts-legally-defined-administrative-areas-of-bc") %>%
    filter(ADMIN_AREA_NAME == "Cariboo Regional District") %>%
    collect()

  ## REMOTE "GEOMETRY"
  em_program <- bcdc_query_geodata("employment-program-of-british-columbia-regional-boundaries") %>%
    filter(INTERSECTS(crd)) %>%
    collect()
  expect_is(em_program, "sf")
  expect_equal(attr(em_program, "sf_column"), "geometry")

  ## REMOTE "SHAPE"
  crd_fires <- bcdc_query_geodata("fire-perimeters-historical") %>%
    filter(FIRE_YEAR == 2000, FIRE_CAUSE == "Person", INTERSECTS(crd)) %>%
    collect()
  expect_is(crd_fires, "sf")
  expect_equal(attr(crd_fires, "sf_column"), "geometry")

})

test_that("Different combinations of predicates work", {
  the_bbox <- st_sfc(st_polygon(
    list(structure(c(1670288.515, 1719022.009,
                     1719022.009, 1670288.515, 1670288.515, 667643.77, 667643.77,
                     745981.738, 745981.738, 667643.77), .Dim = c(5L, 2L)))),
    crs = 3005)

  # with raw CQL
  expect_equal(as.character(cql_translate(CQL('"POP_2000" < 2000'))),
               "(\"POP_2000\" < 2000)")

  # just with spatial predicate
  expect_equal(as.character(cql_translate(WITHIN(the_bbox))),
               "(WITHIN({geom_name}, POLYGON ((1670289 667643.8, 1719022 667643.8, 1719022 745981.7, 1670289 745981.7, 1670289 667643.8))))")

  # spatial predicate combined with regular comparison using comma
  and_statement <- "((WITHIN({geom_name}, POLYGON ((1670289 667643.8, 1719022 667643.8, 1719022 745981.7, 1670289 745981.7, 1670289 667643.8)))) AND (\"POP_2000\" < 2000))"
  expect_equal(as.character(cql_translate(WITHIN(the_bbox), POP_2000 < 2000L)),
               and_statement)

  # spatial predicate combined with regular comparison as a named object using comma
  pop <- 2000L
  expect_equal(as.character(cql_translate(WITHIN(the_bbox), POP_2000 < pop)),
               and_statement)

  and_with_logical <- "(WITHIN({geom_name}, POLYGON ((1670289 667643.8, 1719022 667643.8, 1719022 745981.7, 1670289 745981.7, 1670289 667643.8))) AND \"POP_2000\" < 2000)"
  # spatial predicate combined with regular comparison as a named object using
  # explicit &
  expect_equal(as.character(cql_translate(WITHIN(the_bbox) & POP_2000 < pop)),
               and_with_logical)

  # spatial predicate combined with regular comparison as a named object using
  # explicit |
  or_statement <- "(WITHIN({geom_name}, POLYGON ((1670289 667643.8, 1719022 667643.8, 1719022 745981.7, 1670289 745981.7, 1670289 667643.8))) OR \"POP_2000\" < 2000)"
  expect_equal(as.character(cql_translate(WITHIN(the_bbox) | POP_2000 < pop)),
               or_statement)

  # spatial predicate combined with CQL using comma
  expect_equal(as.character(cql_translate(WITHIN(the_bbox),
                                          CQL("\"POP_2000\" < 2000"))),
               and_statement)

  # spatial predicate combined with CQL using explicit &
  expect_equal(as.character(cql_translate(WITHIN(the_bbox) &
                                            CQL("\"POP_2000\" < 2000"))),
               and_with_logical)

  # spatial predicate combined with CQL using explicit &
  expect_equal(as.character(cql_translate(WITHIN(the_bbox) |
                                            CQL("\"POP_2000\" < 2000"))),
               or_statement)
})

test_that("subsetting works locally", {
  x <- c("a", "b")
  y <- data.frame(id = x, stringsAsFactors = FALSE)
  expect_equal(as.character(cql_translate(foo == x[1])),
               "(\"foo\" = 'a')")
  expect_equal(as.character(cql_translate(foo %in% y$id)),
               "(\"foo\" IN ('a', 'b'))")
  expect_equal(as.character(cql_translate(foo %in% y[["id"]])),
               "(\"foo\" IN ('a', 'b'))")
  expect_equal(as.character(cql_translate(foo == y$id[2])),
               "(\"foo\" = 'b')")
})

test_that("large vectors supplied to filter succeed",{

  pori <- bcdc_query_geodata("freshwater-atlas-stream-network") %>%
    filter(WATERSHED_GROUP_CODE %in% "PORI") %>%
    collect()

  expect_silent(bcdc_query_geodata("freshwater-atlas-stream-network") %>%
    filter(WATERSHED_KEY %in% pori$WATERSHED_KEY))

})

test_that("multiple filter statements are additive",{
  airports <- bcdc_query_geodata('76b1b7a3-2112-4444-857a-afccf7b20da8')

  heliports_in_victoria <-  airports %>%
    filter(PHYSICAL_ADDRESS == "Victoria, BC") %>%
    filter(DESCRIPTION == "heliport") %>%
    collect()

  ## this is additive only Victoria, BC should be a physical address
  expect_true(unique(heliports_in_victoria$PHYSICAL_ADDRESS) == "Victoria, BC")

  heliports_one_line <- airports %>%
    filter(PHYSICAL_ADDRESS == "Victoria, BC", DESCRIPTION == "heliport")
  heliports_two_line <- airports %>%
    filter(PHYSICAL_ADDRESS == "Victoria, BC") %>%
    filter(DESCRIPTION == "heliport")

  expect_identical(finalize_cql(heliports_one_line$query_list$CQL_FILTER),
                   finalize_cql(heliports_two_line$query_list$CQL_FILTER))
})

test_that("multiple filter statements are additive with geometric operators",{
  ## LOCAL
  crd <- bcdc_query_geodata("regional-districts-legally-defined-administrative-areas-of-bc") %>%
    filter(ADMIN_AREA_NAME == "Cariboo Regional District") %>%
    collect() %>%
    st_bbox() %>%
    st_as_sfc()

  ## REMOTE "GEOMETRY"
  em_program <- bcdc_query_geodata("employment-program-of-british-columbia-regional-boundaries") %>%
    filter(ELMSD_REGION_BOUNDARY_NAME == "Interior") %>%
    filter(INTERSECTS(crd))

  cql_query <- "((\"ELMSD_REGION_BOUNDARY_NAME\" = 'Interior') AND (INTERSECTS(GEOMETRY, POLYGON ((956376 653960.8, 1397042 653960.8, 1397042 949343.3, 956376 949343.3, 956376 653960.8)))))"

  expect_equal(as.character(finalize_cql(em_program$query_list$CQL_FILTER)),
               cql_query)
})


test_that("an intersect with an object greater than 5E5 bytes automatically gets turned into a bbox",{
  districts <- bcdc_query_geodata("78ec5279-4534-49a1-97e8-9d315936f08b") %>%
    filter(SCHOOL_DISTRICT_NAME %in% c("Greater Victoria", "Prince George","Kamloops/Thompson")) %>%
    collect()

  expect_true(utils::object.size(districts) > 5E5)

  expect_warning(parks <- bcdc_query_geodata(record = "6a2fea1b-0cc4-4fc2-8017-eaf755d516da") %>%
    filter(WITHIN(districts)) %>%
      collect())
})


test_that("an intersect with an object less than 5E5 proceeds",{
  small_districts <- bcdc_query_geodata("78ec5279-4534-49a1-97e8-9d315936f08b") %>%
    filter(SCHOOL_DISTRICT_NAME %in% c("Prince George")) %>%
    collect() %>%
    st_bbox() %>%
    st_as_sfc()


  expect_silent(parks <- bcdc_query_geodata(record = "6a2fea1b-0cc4-4fc2-8017-eaf755d516da") %>%
    filter(WITHIN(small_districts)) %>%
    collect())
})

