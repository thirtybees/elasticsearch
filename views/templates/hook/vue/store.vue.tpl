{*
 * Copyright (C) 2017 thirty bees
 *
 * NOTICE OF LICENSE
 *
 * This source file is subject to the Academic Free License (AFL 3.0)
 * that is bundled with this package in the file LICENSE.md
 * It is also available through the world-wide-web at this URL:
 * http://opensource.org/licenses/afl-3.0.php
 * If you did not receive a copy of the license and are unable to
 * obtain it through the world-wide-web, please send an email
 * to contact@thirtybees.com so we can send you a copy immediately.
 *
 * @author    thirty bees <contact@thirtybees.com>
 * @copyright 2017 thirty bees
 * @license   http://opensource.org/licenses/afl-3.0.php  Academic Free License (AFL 3.0)
 *}
<script type="text/javascript">
  (function () {
    // Initialize the ElasticsearchModule object if it does not exist
    window.ElasticsearchModule = window.ElasticsearchModule || {ldelim}{rdelim};
    window.ElasticsearchModule.client = new $.es.Client({
      hosts: {Elasticsearch::getReadHosts()|json_encode}
    });

    {literal}
//      function setFiltersInUrl(properties) {
//        var selectedFilters = properties.selectedFilters;
//        var query = properties.query;
//
//        var hash = '#q=' + query;
//
//        $.each(selectedFilters, function (filterName, filters) {
//          hash += '/' + filterName + '=';
//          $.each(filters, function (index, filter) {
//            if (index > 1) {
//              hash += '+';
//            }
//
//            hash += filter;
//          });
//        });
//
//        window.location.hash = hash;
//    }

//    function getFiltersFromUrl() {
//      $.each(selectedFilters, function (filterName, filters) {
//        $.each(filters, function (index, filter) {
//          matches += ', { "match": {"' + filterName + '_agg" : { "query": "' + filter +'", "operator": "and" } } }';
//        });
//      });
//    }

    /**
     * Removes empty properties from an object
     */
    function removeEmpty(obj) {
      Object.keys(obj).forEach(function(key) {
        (obj[key] && typeof obj[key] === 'object') && removeEmpty(obj[key]) ||
        (obj[key] === '' || obj[key] === null) && delete obj[key]
      });

      return obj;
    }

    /**
     * Find filters that have been applied in the query
     */
    function findAggregatedFilters(aggregations) {
      var foundFilters = {};

      $.each(aggregations, function (aggregationName, aggregation) {
        var category = null;
        $.each(aggregation.buckets, function (index, bucket) {
          if (!category) {
            category = Object.keys(bucket.name.hits.hits[0]['_source'])[0];
            foundFilters[category] = {};
          }
          foundFilters[category][bucket.key] = true;
        })
      });

      return foundFilters;
    }

    /**
     * Builds the matches part of the query
     *
     * @param selectedFilters
     * @returns {string}
     */
    function buildMatches(selectedFilters) {
      if ($.isEmptyObject(selectedFilters)) {
        return false;
      }

      var matches = '';
      $.each(selectedFilters, function (filterName, filters) {
        $.each(filters, function (index, filter) {
          matches += ', { "match": {"' + filterName + '_agg" : { "query": "' + filter +'", "operator": "and" } } }';
        });
      });

      return matches.substring(2);
    }
    {/literal}

    function updateResults(state, query, elasticQuery, showSuggestions) {
      {* TODO: build the search query via the stored settings *}
      window.ElasticsearchModule.client.search({
        index: '{Configuration::get(Elasticsearch::INDEX_PREFIX)|escape:'javascript':'UTF-8'}_{$shop->id|intval}_{$language->id|intval}',
        body: {
          size: state.limit,
          from: state.offset,
          query: elasticQuery,
          {if !empty($aggregations)}aggs: {$aggregations|json_encode}{/if}
//          _source: [
//            "name",
//            "description_short",
//            "link"
//          ]
        }
      }, function (error, response) {
        if (response.hits && response.hits.hits) {
          // Set the results
          state.results = response.hits.hits;

          // Handle the suggestions
          if (showSuggestions) {
            state.suggestions = $.extend(true, [], _.take(response.hits.hits, 5));
          } else {
            state.suggestions = [];
          }

          // Set the total and max score
          state.total = response.hits.total;
          state.maxScore = response.hits.max_score;

          // Handle the aggregations
          if (response.aggregations) {
            state.aggregations = response.aggregations;
          } else {
            state.aggregations = [];
          }

          // Handle the selected filters
          var aggregatedFilters = findAggregatedFilters(response.aggregations);
          var selectedFilters = $.extend(true, {ldelim}{rdelim}, state.selectedFilters);
          if (!$.isEmptyObject(selectedFilters)) {
            $.each(state.selectedFilters, function (filterName, filters) {
              $.each(filters, function (index, filter) {
                if (!aggregatedFilters[filterName][filter]) {
                  delete(selectedFilters[filterName][index]);
                }
              });
            });
          }

          state.selectedFilters = selectedFilters;

//          setFiltersInUrl({
//            query: state.query,
//            selectedFilters: selectedFilters
//          });
        }
      });
    }

    window.ElasticsearchModule.store = new Vuex.Store({
      state: {
        query: '',
        results: [],
        total: 0,
        maxScore: 0,
        suggestions: [],
        aggregations: {ldelim}{rdelim},
        limit: 12,
        offset: 0,
        selectedFilters: {ldelim}{rdelim},
        metas: {$metas|json_encode}
      },
      mutations: {
        setQuery: function (state, payload) {
          state.query = payload.query;
          state.offset = 0;

          updateResults(state, payload.query, this.getters.elasticQuery, payload.showSuggestions);
        },
        setResults: function (state, payload) {
          state.results = payload.results;
        },
        resetSuggestions: function (state) {
          state.suggestions = $.extend(true, [], _.take(state.results, 5));
        },
        eraseSuggestions: function (state) {
          state.suggestions = [];
        },
        setLimit: function (state, limit) {
          state.limit = limit;
          state.offset = 0;

          updateResults(state, state.query, this.getters.elasticQuery, false)
        },
        setOffset: function (state, offset) {
          state.offset = offset;
        },
        setPage: function (state, page) {
          state.offset = state.limit * (page - 1);

          updateResults(state, state.query, this.getters.elasticQuery, false);
        },
        toggleSelectedFilter: function (state, payload) {
          var shouldEnable = true;
          if (typeof state.selectedFilters[payload.code] === 'undefined') {
            state.selectedFilters[payload.code] = [];
            shouldEnable = true;
          } else {
            shouldEnable = state.selectedFilters[payload.code].indexOf(payload.filter) < 0;
          }

          if (shouldEnable) {
            state.selectedFilters[payload.code].push(payload.filter);
          } else {
            state.selectedFilters[payload.code].splice(state.selectedFilters[payload.code].indexOf(payload.filter), 1);
            if (!state.selectedFilters[payload.code].length) {
              delete state.selectedFilters[payload.code];
            }
          }

          if (typeof state.selectedFilters === 'undefined') {
            state.selectedFilters = {ldelim}{rdelim};
          }

          updateResults(state, state.query, this.getters.elasticQuery, false)
        }
      },
      getters: {
        elasticQuery: function (state) {
          var matches = buildMatches(state.selectedFilters);

          return JSON.parse('{ElasticSearch::jsonEncodeQuery(Configuration::get(ElasticSearch::QUERY_JSON))|escape:'javascript':'UTF-8'}'
            {literal}
            .replace('||QUERY||', '"query": "' + state.query + '"')
            .replace('||FIELDS||', '"fields": ["name", "description", "description_short", "reference"]')
            .replace('||MATCHES_APPEND||', matches ? ',' + matches : '')
            .replace('||MATCHES_PREPEND||', matches ?  matches + ',' : '')
            .replace('||MATCHES_STANDALONE||', matches ? matches : ''));
            {/literal}
        }
      }
    });
  }());
</script>
