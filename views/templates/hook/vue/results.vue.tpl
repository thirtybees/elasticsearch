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
{* Include dependencies *}
{capture name="resultsTemplate"}{include file=ElasticSearch::tpl('front/search.tpl')}{/capture}
{include file=ElasticSearch::tpl('hook/vue/results/stock-badge.vue.tpl')}
{include file=ElasticSearch::tpl('hook/vue/results/product-section.vue.tpl')}
{include file=ElasticSearch::tpl('hook/vue/results/product-count.vue.tpl')}
{include file=ElasticSearch::tpl('hook/vue/results/show-all.vue.tpl')}
{include file=ElasticSearch::tpl('hook/vue/results/pagination.vue.tpl')}
{include file=ElasticSearch::tpl('hook/vue/results/product-list-item.vue.tpl')}

{* Template file *}
{capture name="template"}{include file=ElasticSearch::tpl('hook/vue/results/results.html.tpl')}{/capture}
<script type="text/javascript">
  (function () {
    function ready(fn) {
      if (document.readyState !== 'loading') {
        fn();
      } else if (document.addEventListener) {
        document.addEventListener('DOMContentLoaded', fn);
      } else {
        document.attachEvent('onreadystatechange', function () {
          if (document.readyState !== 'loading') {
            fn();
          }
        });
      }
    }

    function manageSearchBlockVisibility(state) {
      var instantSearchBlock = document.getElementById('elasticsearch-results');

      if (state.query || state.fixedFilter) {
        mainColumn.style.display = 'none';
        if (_.isElement(instantSearchBlock)) {
          instantSearchBlock.style.display = '';
        }
      } else {
        mainColumn.style.display = '';
        if (_.isElement(instantSearchBlock)) {
          instantSearchBlock.style.display = 'none';
        }
      }
    }

    ready(function () {
      // Check if Elasticsearch is active
      var target = document.getElementById('elasticsearch-results');
      if (typeof target === 'undefined' || !target) {
        mainColumn = document.querySelectorAll('#top_column, #main_column, #center_column');
        if (!mainColumn.length) {
          return;
        }

        // Take the first element
        mainColumn = mainColumn[0];
        mainColumn.insertAdjacentHTML('beforebegin', '{$smarty.capture.resultsTemplate|escape:'javascript':'UTF-8'}');
        target = document.getElementById('elasticsearch-results');
        // Apply the same classlist
        window.ElasticsearchModule = window.ElasticsearchModule || {ldelim}{rdelim};
        window.ElasticsearchModule.classList = mainColumn.classList.value;
      }

      if (typeof target === 'undefined' || !target) {
        new Vue({
          beforeUpdate: function () {
            // Not `undefined` means we're dealing with instant search
            if (typeof mainColumn !== 'undefined') {
              manageSearchBlockVisibility(this.$store.state);
            }
          },
          created: function () {
            var view = '{if Configuration::get(Elasticsearch::PRODUCT_LIST)}list{else}grid{/if}';
            if (typeof window.localStorage !== 'undefined') {
              var localView = window.localStorage.getItem('es-display');
              if (_.indexOf(['grid', 'list'], localView) > -1) {
                view = localView;
              }
            }

            this.$store.commit('setLayoutType', view);
          },
          mounted: function () {
            if (typeof mainColumn !== 'undefined') {
              manageSearchBlockVisibility(this.$store.state);
            }
          },
          directives: {
            InfiniteScroll: window.infiniteScroll
          },
          delimiters: ['%%', '%%'],
          el: target,
          template: '{$smarty.capture.template|escape:'javascript':'UTF-8'}',
          store: window.ElasticsearchModule.store,
          computed: {
            query: function () {
              return this.$store.state.query;
            },
            layoutType: function () {
              return this.$store.state.layoutType;
            },
            classList: function () {
              return window.ElasticsearchModule.classList;
            },
            infiniteScroll: function () {
              return this.$store.state.infiniteScroll;
            },
            fixedFilter: function () {
              return this.$store.state.fixedFilter;
            }
          }
        });
      }
    });
  }());
</script>
