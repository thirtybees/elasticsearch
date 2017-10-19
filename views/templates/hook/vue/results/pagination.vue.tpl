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
{capture name="template"}{include file=ElasticSearch::tpl('hook/vue/results/pagination.html.tpl')}{/capture}
<script type="text/javascript">
  (function () {
    // Initialize the ElasticsearchModule and components objects if they do not exist
    window.ElasticsearchModule = window.ElasticsearchModule || {ldelim}{rdelim};
    window.ElasticsearchModule.components = window.ElasticsearchModule.components || {ldelim}{rdelim};

    window.ElasticsearchModule.components.pagination = {
      delimiters: ['%%', '%%'],
      template: "{$smarty.capture.template|escape:'javascript':'UTF-8'}",
      props: ['limit', 'offset', 'total'],
      computed: {
        page: function () {
          if (!this.offset) {
            return 1;
          }

          return Math.ceil(this.offset / this.limit)  + 1;
        },
        nbPages: function () {
          return Math.ceil(this.total / this.limit);
        }
      },
      methods: {
        setPage: function (page) {
          if (page < 1) {
            page = 1;
          }

          if (page > this.nbPages) {
            page = nbPages;
          }

          this.$store.commit('setPage', page);
        }
      }
    };
  }());
</script>
