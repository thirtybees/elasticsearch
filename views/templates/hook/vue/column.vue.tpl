{*
 * Copyright (C) 2017-2018 thirty bees
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
 * @copyright 2017-2018 thirty bees
 * @license   http://opensource.org/licenses/afl-3.0.php  Academic Free License (AFL 3.0)
 *}
{* Include rangeslider component *}
{include file=ElasticSearch::tpl('hook/vue/results/rangeslider.vue.tpl')}

{* Template file *}
{capture name="template"}{include file=ElasticSearch::tpl('hook/vue/column.html.tpl')}{/capture}
<script type="text/javascript">
  (function () {
    Vue.component('elasticsearch-column', {
      delimiters: ['%%', '%%'],
      template: "{$smarty.capture.template|escape:'javascript':'UTF-8'}",
      store: window.ElasticsearchModule.store,
      data: function () {
        return {
          availableAggregations: {$aggregations|json_encode},
          value: 0
        };
      },
      mounted: function () {
        this.$store.commit('addColumn');
      },
      computed: {
        aggregations: function () {
          return _.sortBy(_.values(this.$store.state.aggregations), function (agg) {
            return parseInt(agg.position, 10);
          });
        },
        query: function () {
          return this.$store.state.query;
        },
        selectedFilters: function () {
          return this.$store.state.selectedFilters;
        },
        fixedFilter: function () {
          return this.$store.state.fixedFilter;
        },
        total: function () {
          return this.$store.state.total;
        },
        tax: function () {
          return this.$store.state.tax;
        },
        currencyConversion: function () {
          return this.$store.state.currencyConversion;
        }
      },
      methods: {
        formatCurrency: function (price) {
          return window.formatCurrency(price, window.currencyFormat, window.currencySign, window.currencyBlank);
        },
        findDisplayType: function (aggregationCode) {
          return parseInt(this.$store.state.metas[aggregationCode].display_type, 10);
        },
        findOperator: function (aggregationCode) {
          return (parseInt(this.$store.state.metas[aggregationCode].operator, 10) === 1 ? 'OR' : 'AND');
        },
        findMin: function (code) {
          return Math.min(this.findSelectedMin(code), Math.floor(this.getPriceInclTax(this.$store.state.aggregations[code].buckets[0].min)));
        },
        findMax: function (code) {
          return Math.max(this.findSelectedMax(code), Math.ceil(this.getPriceInclTax(this.$store.state.aggregations[code].buckets[0].max)));
        },
        findSelectedMin: function (code) {
          if (typeof this.selectedFilters[code] !== 'undefined') {
            return this.selectedFilters[code].values.min;
          }

          return Math.floor(this.getPriceInclTax(this.$store.state.aggregations[code].buckets[0].min));
        },
        findSelectedMax: function (code) {
          if (typeof this.selectedFilters[code] !== 'undefined') {
            return this.selectedFilters[code].values.max;
          }

          return Math.ceil(this.getPriceInclTax(this.$store.state.aggregations[code].buckets[0].max));
        },
        toggleFilter: function (aggregationCode, aggregationName, filterCode, filterName) {
          if (this.$store.state.fixedFilter
            && this.$store.state.fixedFilter.aggregationCode === aggregationCode
            && this.$store.state.fixedFilter.filterCode === filterCode
          ) {
            return;
          }

          this.$store.commit('toggleSelectedFilter', {
            filterCode: filterCode,
            filterName: filterName,
            aggregationCode: aggregationCode,
            aggregationName: aggregationName,
            displayType: this.findDisplayType(aggregationCode),
            operator: this.findOperator(aggregationCode),
            checked: !this.isFilterChecked(aggregationCode, filterCode)
          });
        },
        removeFilter: function (aggregationCode, aggregationName, filterCode, filterName) {
          if (this.$store.state.fixedFilter
            && this.$store.state.fixedFilter.aggregationCode === aggregationCode
            && this.$store.state.fixedFilter.filterCode === filterCode
          ) {
            return;
          }

          this.$store.commit('toggleSelectedFilter', {
            filterName: filterName,
            filterCode: filterCode,
            aggregationName: aggregationName,
            aggregationCode: aggregationCode,
            checked: false
          });
        },
        addOrUpdateRangeFilter: function (aggregationCode, aggregationName, min, max) {
          this.$store.commit('addOrUpdateSelectedRangeFilter', {
            code: aggregationCode,
            name: aggregationName,
            min: min,
            min_tax_excl: min / (this.tax * this.currencyConversion),
            max: max,
            max_tax_excl: max / (this.tax * this.currencyConversion)
          });
        },
        removeRangeFilter: function (aggregationCode) {
          this.$store.commit('removeSelectedRangeFilter', {
            code: aggregationCode,
          });
        },
        isFilterChecked: function (aggregationCode, filterCode) {
          if (typeof this.selectedFilters[aggregationCode] !== 'undefined'
            && typeof this.selectedFilters[aggregationCode].values !== 'undefined') {
            return _.findIndex(this.selectedFilters[aggregationCode].values, ['code', filterCode]) > -1;
          }

          return false;
        },
        processRangeSlider: function (aggregationCode, aggregationName, event) {
          var min = Math.floor(Math.min(parseInt(event.val[0], 10), parseInt(event.val[1], 10)));
          var max = Math.ceil(Math.max(parseInt(event.val[0], 10), parseInt(event.val[1], 10)));

          // Prevent out of range selections
          if (max <= min) {
            if (min > this.findMin(aggregationCode)) {
              min = parseInt(this.findMin(aggregationCode), 10);
            }

            max = min + 1;
          }

          this.addOrUpdateRangeFilter(aggregationCode, aggregationName, min, max);
        },
        getPriceInclTax: function (price) {
          return Math.round(price * this.tax * this.currencyConversion);
        },
        hasFixedFilter: function (aggregationCode) {
          if (!this.fixedFilter) {
            return false;
          }

          return this.fixedFilter.aggregationCode === aggregationCode || aggregationCode === '{Elasticsearch::getAlias('category')|escape:'javascript':'UTF-8'}'
            && this.fixedFilter.aggregationCode === '{Elasticsearch::getAlias('categories')|escape:'javascript':'UTF-8'}';
        }
      }
    });
  }());
</script>
