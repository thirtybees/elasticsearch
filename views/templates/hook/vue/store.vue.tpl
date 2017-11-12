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
    // Pending ajax search requests - cancel these with every new search
    var pendingRequests = {ldelim}{rdelim};

    // Round robin function
    // Credits to  JP Richardson (https://github.com/jprichardson/rr)
    function rr (arr, lastIndex) {
      if (!Array.isArray(arr)) {
        throw new Error("Input is not an array.");
      }

      if (arr.length === 0) {
        return null;
      }

      if (arr._rr === null) {
        arr._rr = 0;

        return arr[0];
      }

      if (arr.length === 1) {
        return arr[0];
      }

      if (typeof lastIndex === 'number')
        arr._rr = lastIndex;

      //is outside of range?
      if (arr._rr >= arr.length - 1 || arr._rr < 0) {
        arr._rr = 0;
        return arr[0]
      } else {
        arr._rr += 1;
        return arr[arr._rr]
      }
    }

    function normalizeAggregations(aggs) {
      // The main list
      var aggregations = {ldelim}{rdelim};

      // Iterating the aggregations returned by Elasticsearch and starting the normalization process
      _.forEach(aggs, function (agg, aggCode) {
        // Check if this aggregation should be processed
        if (typeof agg.buckets !== 'undefined' && !agg.buckets.length) {
          return;
        }

        // Handle the aggregation according to the display type
        var displayType = parseInt(agg.meta.display_type, 10);

        var actualAggCode = aggCode;
        if (displayType === 4) {
          actualAggCode = aggCode.substring(0, aggCode.length - 4); // Aggregation name minus the _min or _max part at the end
        }

        //The normalized aggregations
        var aggregation = {
          code: actualAggCode,
          name: agg.meta.name,
          position: agg.meta.position,
          display_type: displayType,
          buckets: []
        };

        if (displayType === 4) {
          // Slider
          var aggType = aggCode.substring(aggCode.length - 3); // Aggregation type

          // If the slider aggregation already exists, we only need to add the current min/max
          if (typeof aggregations[actualAggCode] !== 'undefined') {
            aggregations[actualAggCode].buckets[0][aggType] = agg.value;

            return;
          }

          // Create the slider buckets
          var newBucket = {ldelim}{rdelim};
          newBucket[aggType] = agg.value;
          aggregation.buckets.push(newBucket);
        } else if (displayType === 5) {
          // Color
          _.forEach(agg.buckets, function (bucket) {
            // Ensure we have a names array
            var position = 0;
            var key = bucket.key;

            var codes = bucket.code.hits.hits[0]._source[aggCode + '_agg'];
            if (!_.isArray(codes)) {
              codes = [codes];
            } else {
              // Search the position we will have to use
              position = _.indexOf(codes, key);
              if (position < 0) {
                position = 0;
              }
            }

            var names = bucket.name.hits.hits[0]._source[aggCode];
            if (!_.isArray(names)) {
              names = [names];
            }

            var colorCodes = bucket.color_code.hits.hits[0]._source[aggCode + '_color_code'];
            if (!_.isArray(colorCodes)) {
              colorCodes = [colorCodes];
            }

            var code = codes[position];
            var name = names[position];
            var colorCode = colorCodes[position];

            // Check if bucket already exists
            var newBucket = _.find(aggregation.buckets, ['code', code]);
            if (typeof newBucket === 'object') {
              newBucket.total += bucket.doc_count;
            } else {
              aggregation.buckets.push({
                code: code,
                name: name,
                color_code: colorCode,
                total: bucket.doc_count
              });
            }
          });
        } else {
          // Checkbox
          _.forEach(agg.buckets, function (bucket) {
            // Ensure we have a names array
            var position = 0;
            var key = bucket.key;

            var codes = bucket.code.hits.hits[0]._source[aggCode + '_agg'];
            if (!_.isArray(codes)) {
              codes = [codes];
            } else {
              // Search the position we will have to use
              position = _.indexOf(codes, key);
              if (position < 0) {
                position = 0;
              }
            }

            var names = bucket.name.hits.hits[0]._source[aggCode];
            if (!_.isArray(names)) {
              names = [names];
            }

            var code = codes[position];
            var name = names[position];

            // Check if bucket already exists
            var newBucket = _.find(aggregation.buckets, ['code', code]);
            if (typeof newBucket === 'object') {
              newBucket.total += bucket.doc_count;
            } else {
              aggregation.buckets.push({
                code: code,
                name: name,
                total: bucket.doc_count
              });
            }
          });
        }

        aggregations[actualAggCode] = aggregation;
      });

      return aggregations;
    }

    // Initialize the ElasticsearchModule object if it does not exist
    window.ElasticsearchModule = window.ElasticsearchModule || {ldelim}{rdelim};
    window.ElasticsearchModule.hosts = {Elasticsearch::getFrontendHosts()|json_encode};

    {literal}
//      function setFiltersInUrl(properties) {
//        var selectedFilters = properties.selectedFilters;
//        var query = properties.query;
//
//        var hash = '#q=' + query;
//
//        _.forEach(selectedFilters, function (filters, filterName) {
//          hash += '/' + filterName + '=';
//          _.forEach(filters, function (filter, index) {
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
//      _.forEach(selectedFilters, function (filters, filterName) {
//        _.forEach(filters, function (filter, index) {
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
     *
     * @fixme: use normalized format
     */
    function findAggregatedFilters(aggregations) {
      var foundFilters = {};

      _.forEach(aggregations, function (aggregation) {
        var category = null;
        _.forEach(aggregation.buckets, function (bucket) {
          if (!category) {
            category = Object.keys(bucket.name.hits.hits[0]._source)[0];
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
      if (_.isEmpty(selectedFilters)) {
        return false;
      }

      var matches = '';
      _.forEach(selectedFilters, function (filters, filterName) {
        if (parseInt(filters.display_type, 10) === 4) {
          var aggregationCode = filters.code;
          if (aggregationCode === 'price_tax_excl') {
            aggregationCode += '_group_{/literal}{Context::getContext()->customer->id_default_group|intval}{literal}';
          }

          matches += ', { "range": {"' + aggregationCode + '_agg" : { "gte": ' + filters.values.min_tax_excl + ', "lte": ' + filters.values.max_tax_excl + ' } } }';
        } else {
          _.forEach(filters.values, function (filter) {
            matches += ', { "match": {"' + filterName + '_agg" : { "query": "' + filter.code + '", "operator": "' + (filters.operator ? filters.operator : 'AND') + '" } } }';
          });
        }
      });

      // Remove ` ,`
      return matches.substring(2);
    }
    {/literal}

    function updateResults(state, query, elasticQuery, showSuggestions) {
      // Check if this request should be proxied
      var proxied = {if Configuration::get(Elasticsearch::PROXY)}true{else}false{/if};

      // Create a virtual `<a>` element to parse the URL
      var parser = document.createElement('a');
      // Assign a host (using Round Robin load balancing)
      parser.href = rr(window.ElasticsearchModule.hosts);

      // Build the URL
      var url = parser.protocol + '//' + parser.host + parser.pathname;
      if (!proxied) {
        url += '{Configuration::get(Elasticsearch::INDEX_PREFIX)|escape:'javascript':'UTF-8'}_{$shop->id|intval}_{$language->id|intval}/_search';
      }

      // Cancel pending requests and remove references to them, so the browser can start cleaning up
      _.forEach(pendingRequests, function (request) {
        request.abort();
      });
      pendingRequests = {ldelim}{rdelim};

      // Get a timestamp for the request
      var timestamp = + new Date();

      // Create a new POST request
      var request = new XMLHttpRequest();
      request.open('POST', url, true);
      // Data type is JSON
      request.setRequestHeader('Content-Type', 'application/json; charset=UTF-8');

      // Set the proxy header if proxy is enabled
      if (proxied) {
        request.setRequestHeader('X-Elasticsearch-Proxy', 'magic');
      }

      // Set the Basic Auth header if authorization is required
      if (parser.username && parser.password) {
        request.setRequestHeader("Authorization", "Basic " + btoa(parser.username + ':' + parser.password));
      }

      // Ready state = 4 => the request is finished
      request.onreadystatechange = function() {
        if (this.readyState === 4) {
          // Remove references to this request
          delete pendingRequests[timestamp];

          // Response should be JSON
          var response;
          try {
            response = JSON.parse(this.responseText);
          } catch (e) {
            response = null;
          }

          // These statuses mean a successful request
          if (this.status >= 200 && this.status < 400) {
            // Success!

            // Process response
            if (response.hits && response.hits.hits) {
              // Set the results
              state.results = response.hits.hits;

              // Handle the suggestions
              if (showSuggestions) {
                state.suggestions = _.cloneDeep(_.take(response.hits.hits, 5));
              } else {
                state.suggestions = [];
              }

              // Set the total and max score
              state.total = response.hits.total;
              state.maxScore = response.hits.max_score;

              // Handle the aggregations
              if (response.aggregations) {
                state.aggregations = normalizeAggregations(response.aggregations);
              } else {
                state.aggregations = [];
              }

              // Handle the selected filters - remove anything that is not aggregatable
              // Start with a clone, do not alter the array directly
              // FIXME: is not workss!
//              var selectedFilters = _.cloneDeep(state.selectedFilters);
//              if (!_.isEmpty(selectedFilters)) {
//
//                _.forEach(state.selectedFilters, function (filters, filterName) {
//                  _.forEach(filters, function (filter) {
//                    var position = -1;
//                    var finger = 0;
//
//                    _.forEach(filter.values, function (item) {
//                      if (item.code === bucket.key) {
//                        position = finger;
//
//                        return false;
//                      }
//                      finger++;
//                    });
//
//                    if (position > -1) {
//                      selectedFilters[filterName] = _.pullAt(selectedFilters[filterName], position);
//                    }
//                  });
//                });
//              }

//              Vue.set(state, 'selectedFilters', selectedFilters);
            }
          } else {
            // Error :(
          }

          // Finally
        }
      };

      request.send(JSON.stringify({
        size: state.limit,
        from: state.offset,
        query: elasticQuery,
        highlight: {
          fields: {
            name: {ldelim}{rdelim}
          },
          pre_tags: ['<span class="es-highlight">'],
          post_tags: ['</span>']
        },
        {if !empty($aggregations)}aggs: {$aggregations|json_encode}{/if}
//          _source: [
//            "name",
//            "description_short",
//            "link"
//          ]
      }));

      // Save these in the pending requests array
      pendingRequests[timestamp] = request;
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
        metas: {$metas|json_encode},
        layoutType: null
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
          state.suggestions = _.cloneDeep(_.take(state.results, 5));
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
        setLayoutType: function (state, layoutType) {
          state.layoutType = layoutType;
        },
        toggleSelectedFilter: function (state, payload) {
          var shouldEnable = payload.checked;
          var selectedFilters = _.cloneDeep(state.selectedFilters);
          if (typeof selectedFilters[payload.aggregationCode] === 'undefined') {
            selectedFilters[payload.aggregationCode] = {
              name: payload.aggregationName,
              code: payload.aggregationCode,
              operator: payload.operator,
              values: []
            };
          }

          if (shouldEnable) {
            selectedFilters[payload.aggregationCode].values.push({
              code: payload.filterCode,
              name: payload.filterName
            });
          } else {
            var position = -1;
            var finger = 0;
            _.forEach(selectedFilters[payload.aggregationCode].values, function (item) {
              if (item.code === payload.filterCode) {
                position = finger;

                return false;
              }
              finger++;
            });

            selectedFilters[payload.aggregationCode].values.splice(position, 1);
            if (!selectedFilters[payload.aggregationCode].values.length) {
              delete selectedFilters[payload.aggregationCode];
            }
          }

          if (typeof selectedFilters === 'undefined') {
            selectedFilters = {ldelim}{rdelim};
          }

          state.offset = 0;

          Vue.set(state, 'selectedFilters', selectedFilters);

          updateResults(state, state.query, this.getters.elasticQuery, false);
        },
        addOrUpdateSelectedRangeFilter: function (state, payload) {
          var selectedFilters = _.cloneDeep(state.selectedFilters);
          selectedFilters[payload.code] = {
            code: payload.code,
            name: payload.name,
            display_type: 4,
            values: {
              min: payload.min,
              min_tax_excl: payload.min_tax_excl,
              max: payload.max,
              max_tax_excl: payload.max_tax_excl
            }
          };

          state.offset = 0;

          Vue.set(state, 'selectedFilters', selectedFilters);

          updateResults(state, state.query, this.getters.elasticQuery, false);
        },
        removeSelectedRangeFilter: function (state, payload) {
          var selectedFilters = _.cloneDeep(state.selectedFilters);

          delete selectedFilters[payload.code];

          state.offset = 0;

          Vue.set(state, 'selectedFilters', selectedFilters);

          updateResults(state, state.query, this.getters.elasticQuery, false);
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
