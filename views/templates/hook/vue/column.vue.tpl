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
{* Template file *}
{capture name="template"}{include file=ElasticSearch::tpl('hook/vue/column.html.tpl')}{/capture}
<script type="text/javascript">
  (function () {
    // Initialize the ElasticsearchModule and components objects if they do not exist
    window.ElasticsearchModule = window.ElasticsearchModule || {ldelim}{rdelim};
    window.ElasticsearchModule.components = window.ElasticsearchModule.components || {ldelim}{rdelim};

    window.ElasticsearchModule.components.column = {
      delimiters: ['%%', '%%'],
      template: "{$smarty.capture.template|escape:'javascript':'UTF-8'}",
      store: window.ElasticsearchModule.store,
      data: function () {
        return {
          availableAggregations: {$aggregations|json_encode}
        };
      },
      computed: {
        aggregations: function () {
          return _.sortBy(_.values(this.$store.state.aggregations), function (agg) {
            return parseInt(agg.meta.position, 10);
          });
        },
        selectedFilters: function () {
          return this.$store.state.selectedFilters;
        }
      },
      methods: {
        findName: function (bucket) {
          if (typeof bucket['name'] !== 'undefined'
            && typeof bucket['name']['hits'] !== 'undefined'
            && typeof bucket['name']['hits']['hits'] !== 'undefined'
            && typeof bucket['name']['hits']['hits'][0] !== 'undefined'
            && typeof bucket['name']['hits']['hits'][0]['_source'] !== 'undefined') {
            var name = Object.values(bucket['name']['hits']['hits'][0]['_source'])[0];
            // If it's an array we might be dealing with a color
            if (_.isArray(name)) {
              return name[0];
            }

            return name;
          }

          throw JSON.stringify(bucket);
        },
        findCode: function (bucket) {
          if (typeof bucket.name !== 'undefined'
            && typeof bucket.name.hits !== 'undefined'
            && typeof bucket.name.hits.hits !== 'undefined'
            && typeof bucket.name.hits.hits[0] !== 'undefined'
            && typeof bucket.name.hits.hits[0]._source !== 'undefined') {
            return Object.keys(bucket.name.hits.hits[0]._source)[0];
          }

          return false;
        },
        findColorCode: function (bucket) {
          if (typeof bucket['color_code'] !== 'undefined'
            && typeof bucket['color_code']['hits'] !== 'undefined'
            && typeof bucket['color_code']['hits']['hits'] !== 'undefined'
            && typeof bucket['color_code']['hits']['hits'][0] !== 'undefined'
            && typeof bucket['color_code']['hits']['hits'][0]['_source'] !== 'undefined') {
            var name = Object.values(bucket['color_code']['hits']['hits'][0]['_source'])[0];
            // If it's an array we might be dealing with a color
            if (_.isArray(name)) {
              return name[0];
            }

            return name;
          }

          return '#000000';
        },
        findDisplayType: function (bucket) {
          var code = this.findCode(bucket);

          if (typeof this.$store.state.metas[code] !== 'undefined') {
            return this.$store.state.metas[code].display_type;
          }

          return 0;
        },
        findPosition: function (bucket) {
          var code = this.findCode(bucket);

          if (typeof this.$store.state.metas[code] !== 'undefined') {
            return this.$store.state.metas[code].position;
          }

          return Infinity;
        },
        findAggregationName: function (bucket) {
          var code = this.findCode(bucket);

          return this.$store.state.metas[code].name;
        },
        findOperator: function (bucket) {
          var code = this.findCode(bucket);

          return (parseInt(this.$store.state.metas[code].operator, 10) === 1 ? 'OR' : 'AND');
        },
        toggleFilter: function (bucket) {
          var aggregationCode = this.findCode(bucket);
          var filterName = this.findName(bucket);
          var aggregationName = this.findAggregationName(bucket);
          var operator = this.findOperator(bucket);
          var checked = this.isFilterChecked(bucket);

          this.$store.commit('toggleSelectedFilter', {
            filterName: filterName,
            filterCode: bucket.key,
            aggregationName: aggregationName,
            aggregationCode: aggregationCode,
            operator: operator,
            checked: !checked
          });
        },
        removeFilter: function (aggregationCode, aggregationName, filterCode, filterName) {
          this.$store.commit('toggleSelectedFilter', {
            filterName: filterName,
            filterCode: filterCode,
            aggregationName: aggregationName,
            aggregationCode: aggregationCode,
            checked: false
          });
        },
        isFilterChecked: function (bucket) {
          var code = this.findCode(bucket);

          if (typeof this.selectedFilters[code] !== 'undefined'
            && typeof this.selectedFilters[code].values !== 'undefined') {
            console.log(JSON.stringify(this.selectedFilters[code]));
            var position = -1;
            var finger = 0;
            _.forEach(this.selectedFilters[code].values, function (filter) {
              if (filter.code === bucket.key) {
                position = finger;

                return false;
              }
              finger++;
            });

            return position > -1;
          }

          return false;
        }
      }
    };
  }());
</script>
