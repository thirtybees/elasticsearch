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
    var initialFixedFilter = {if $fixedFilter}{$fixedFilter|json_encode}{else}null{/if};

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
        if (typeof agg.code.buckets !== 'undefined' && !agg.code.buckets.length) {
          return;
        }

        var buckets = [];
        _.forEach(agg.code.buckets, function (b, index) {
          var bucket = _.cloneDeep(b);
          if (typeof agg.name !== 'undefined') {
            bucket.name = agg.name.buckets[index].name;
          }
          if (typeof agg.color_code !== 'undefined') {
            bucket.color_code = agg.color_code.buckets[index].color_code;
          }

          buckets.push(bucket);
        });

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
          _.forEach(buckets, function (bucket) {
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
          _.forEach(buckets, function (bucket) {
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

    function fixMissingFilterInfo(state) {
      _.forEach(state.selectedFilters, function (selectedFilter) {
        if (parseInt(selectedFilter, 10) !== 4) {
          _.forEach(selectedFilter.values, function (value) {
            if (typeof state.aggregations[selectedFilter.code] === 'undefined') {
              return;
            }

            var fullAggregation = _.find(state.aggregations[selectedFilter.code].buckets, ['code', value.code]);
            if (fullAggregation) {
              value.name = fullAggregation.name;
            }
          });
        }
      });
    }

    function checkFixedFilter(sFilters, fixedFilter) {
      if (!fixedFilter) {
        return sFilters;
      }

      var selectedFilters = _.cloneDeep(sFilters);

      var fixedFilterFound = false;
      _.forEach(selectedFilters, function (selectedFilter, aggregationCode) {
        // Skip range filters
        if (parseInt(selectedFilter.display_type, 10) !== 4) {
          _.forEach(selectedFilter.values, function (value) {
            if (aggregationCode === fixedFilter.aggregationCode && value.code === fixedFilter.filterCode) {
              value.fixed = true;

              fixedFilterFound = true;
              return false;
            }
          });
        }
      });

      if (!fixedFilterFound) {
        if (typeof selectedFilters[fixedFilter.aggregationCode] === 'undefined') {
          selectedFilters[fixedFilter.aggregationCode] = {
            code: fixedFilter.aggregationCode,
            name: fixedFilter.aggregationName,
            operator: 'AND',
            display_type: fixedFilter.displayType,
            values: [
              {
                code: fixedFilter.filterCode,
                name: fixedFilter.filterName,
                fixed: true
              }
            ]
          }
        }
      }

      return selectedFilters;
    }

    // Initialize the ElasticsearchModule object if it does not exist
    window.ElasticsearchModule = window.ElasticsearchModule || {ldelim}{rdelim};
    window.ElasticsearchModule.hosts = {Elasticsearch::getFrontendHosts()|json_encode};

    {literal}
    function filtersToUrl(properties) {
      var selectedFilters = properties.selectedFilters;
      var query = properties.query;

      if (!query) {
        // Remove hash
        if (typeof history.replaceState === 'function') {
          history.replaceState('', document.title, window.location.pathname + window.location.search);
        } else {
          window.location.hash = '';
        }

        return;
      }

      // Start the URL with the query, page and results per page
      var hash = '#q=' + query;
      if (properties.page && properties.page > 1) {
        hash += '/p=' + properties.page;
      }
      if (properties.limit && _.indexOf([24, 36, 'all'], properties.limit) > -1) {
        hash += '/n=' + properties.limit;
      }

      // Add the selected filters to the URL
      _.forEach(selectedFilters, function (aggregation) {
        // Rename price_tax_excl to just price
        var aggregationCode = aggregation.code;
        if (aggregationCode === 'price_tax_excl') {
          aggregationCode = 'price';
        }

        hash += '/' + aggregationCode + '=';
        if (parseInt(aggregation.display_type, 10) !== 4) {
          // We're dealing with 'normal' facets
          _.forEach(aggregation.values, function (filter, index) {
            // In case we have a disjunctive facet, add multiple filter codes with +
            if (index > 0) {
              hash += '+';
            }

            hash += filter.code;
          });
        } else {
          // We're dealing with the price facet
          hash += aggregation.values.min + '-' + aggregation.values.max
        }
      });

      window.location.hash = hash;
    }

    function filtersFromUrl(state) {
      var properties = {
        query: '',
        selectedFilters: {}
      };

      // Take the hash and iterate over every section separated by /
      _.forEach(window.location.hash.replace('#', '').split('/'), function (filterInUrl) {
        // Grab the elements from the section, with disjunctive facets there are multiple values separated by +
        // The first element is the aggregation code, subsequent elements are filter codes
        var filterElems = filterInUrl.split(/[=+]/);
        if (filterElems.length < 2) {
          return;
        }

        var aggregationCode = filterElems[0];
        switch (aggregationCode) {
          case 'q':
            properties.query = filterElems[1];

            return;
          case 'p':
            properties.page = parseInt(filterElems[1]);

            return;
          case 'n':
            properties.limit = filterElems[1];
            if (properties.limit === 'all') {
              properties.limit = 10000;
            } else {
              properties.limit = parseInt(properties.limit, 10);
            }

            return;
          case 'price':
            aggregationCode = 'price_tax_excl';

            break;
        }

        if (typeof state.metas[aggregationCode] === 'undefined') {
          return;
        }

        var meta = state.metas[aggregationCode];

        if (parseInt(meta.display_type, 10) === 4) {
          var range = filterElems[1].split('-');

          if (range.length !== 2) {
            return;
          }

          properties.selectedFilters[aggregationCode] = {
            code: aggregationCode,
            name: meta.name,
            display_type: meta.display_type,
            fixed: false,
            values: {
              min: range[0],
              min_tax_excl: parseFloat(range[0]) / state.tax / state.currencyConversion,
              max: range[1],
              max_tax_excl: parseFloat(range[1]) / state.tax / state.currencyConversion
            }
          }
        } else {
          var values = [];
          _.forEach(filterElems.splice(1), function (filterCode) {
            values.push({
              code: filterCode,
              fixed: false
            });
          });

          var fixed = false;

          properties.selectedFilters[aggregationCode] = {
            code: aggregationCode,
            name: meta.name,
            display_type: meta.display_type,
            operator: (!fixed && parseInt(meta.operator, 10)) ? 'OR' : 'AND',
            values: values
          }
        }

      });

      properties.selectedFilters = checkFixedFilter(properties.selectedFilters, state.fixedFilter);

      return properties;
    }

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
     * @param {array} selectedFilters
     * @param {string} exclude
     * @returns {object}
     */
    function buildFilterQuery(selectedFilters, exclude) {
      // A filter query consists of a main bool of which the subfilters must all be true
      var filterQuery = {
        bool: {
          must: []
        }
      };

      // If empty, just return the main structure
      if (_.isEmpty(selectedFilters)) {
        return filterQuery;
      }

      var filterGroups = {};

      _.forEach(selectedFilters, function (filters, filterName) {
        // Skip the excluded filter
        if (typeof exclude !== 'undefined' && exclude === filterName) {
          return;
        }

        if (parseInt(filters.display_type, 10) === 4) {
          // Special case: price slider
          var aggregationCode = filters.code;
          if (aggregationCode === 'price_tax_excl') {
            aggregationCode += '_group_{/literal}{Context::getContext()->customer->id_default_group|intval}{literal}';
          }

          var range = {};
          range[aggregationCode] = {
            gte: filters.values.min_tax_excl,
            lte: filters.values.max_tax_excl
          };

          filterQuery.bool.must.push({
            bool: {
              must:
                {
                  range: range
                }
            }
          });
        } else {
          // If the filter has the AND operator, just add it directly to the subquery...
          _.forEach(filters.values, function (filter) {
            if (filters.operator === 'AND') {
              var term = {};
              term[filterName + '_agg'] = filter.code;

              filterQuery.bool.must.push({
                bool: {
                  must: {
                    term: term
                  }
                }
              });
            } else {
              // ...otherwise group all of these filters first
              if (typeof filterGroups[filterName] === 'undefined') {
                filterGroups[filterName] = [];
              }

              filterGroups[filterName].push(filter.code);
            }
          });
        }

        // Process the OR filters. This results in another filter of which all the terms should occur
        _.forEach(filterGroups, function (filterCodes, filterName) {
          var subfilterQuery = {
            bool: {
              should: []
            }
          };

          _.forEach(filterCodes, function (filterCode) {
            var term = {};
            term[filterName + '_agg'] = filterCode;

            subfilterQuery.bool.should.push({
              term: term
            });
          });

          filterQuery.bool.must.push(subfilterQuery);
        });
      });

      return filterQuery;
    }
    {/literal}

    function updateResults(state, query, queryObject, showSuggestions, callback) {
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
          if (this.status >= 200
            && this.status < 400
          ) {
            // Success!

            // Process search response
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

              fixMissingFilterInfo(state);

              var page = 1;

              if (state.offset) {
                page = Math.ceil(state.offset / state.limit) + 1;
              }

              var limit = state.limit;
              if (limit === 10000) {
                limit = 'all';
              }

              filtersToUrl({
                selectedFilters: state.selectedFilters,
                query: query,
                page: page,
                limit: limit
              });
            }
          } else {
            // Error :(
          }

          // Finally
          if (typeof callback === 'function') {
            callback(state);
          }
        }
      };

      var aggs = {if !empty($aggregations)}{$aggregations|json_encode}{else}{ldelim}{rdelim}{/if};
      _.forEach(aggs, function (agg, aggName) {
        var filterQuery;
        if (typeof state.selectedFilters[aggName] !== 'undefined' && state.selectedFilters[aggName].operator !== 'OR') {
          filterQuery = buildFilterQuery(state.selectedFilters, null);
        } else {
          filterQuery = buildFilterQuery(state.selectedFilters, aggName);
        }
        filterQuery.bool.must.push({
          terms: agg.terms
        });
        delete agg.terms;

        agg.filter = filterQuery;
      });

      var searchRequest = {
        size: state.limit,
        from: state.offset,
        post_filter: buildFilterQuery(state.selectedFilters),
        highlight: {
          fields: {
            name: {ldelim}{rdelim}
          },
          pre_tags: ['<span class="es-highlight">'],
          post_tags: ['</span>']
        },
        aggs: aggs
      };

      if (!state.fixedFilter) {
        searchRequest.query = queryObject;
      }

      request.send(JSON.stringify(searchRequest));

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
        fixedFilter: {if $fixedFilter}{$fixedFilter|json_encode}{else}null{/if},
        selectedFilters: {ldelim}{rdelim},
        metas: {$metas|json_encode},
        layoutType: null,
        tax: {$defaultTax|floatval},
        currencyConversion: {$currencyConversion|floatval},
        infiniteScroll: {if Configuration::get(Elasticsearch::INFINITE_SCROLL)}true{else}false{/if}
      },
      mutations: {
        initQuery: function (state) {
          var properties = filtersFromUrl(state);
          state.selectedFilters = properties.selectedFilters;
          state.query = properties.query;
          if (!state.query) {
            return;
          }

          var limit = properties.limit;
          if (!limit) {
            limit = 12;
          }
          var offset = properties.page;
          if (!offset) {
            offset = 0;
          } else {
            offset = parseInt(offset, 10);
            offset--;
            if (offset < 0) {
              offset = 0;
            }
          }
          offset = offset * limit;

          state.offset = offset;
          state.limit = limit;

          updateResults(state, properties.query, this.getters.elasticQuery, false);
        },
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
              display_type: payload.displayType,
              operator: payload.operator,
              values: []
            };
          }

          if (shouldEnable) {
            selectedFilters[payload.aggregationCode].values.push({
              code: payload.filterCode,
              name: payload.filterName,
              fixed: false
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

          selectedFilters = checkFixedFilter(selectedFilters, state.fixedFilter);

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
        },
        loadMoreProducts: function (state, callback) {
          state.limit += 12;

          updateResults(state, state.query, this.getters.elasticQuery, false, callback);
        }
      },
      getters: {
        elasticQuery: function (state) {
          return JSON.parse('{ElasticSearch::jsonEncodeQuery(Configuration::get(ElasticSearch::QUERY_JSON))|escape:'javascript':'UTF-8'}'
            .replace('||QUERY||', '"' + state.query + '"')
            .replace('||FIELDS||', '["name", "description", "description_short", "reference"]'));
        }
      }
    });
  }());
</script>
