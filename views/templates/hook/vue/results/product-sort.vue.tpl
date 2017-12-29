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
{* Template file *}
{capture name="template"}{include file=ElasticSearch::tpl('hook/vue/results/product-sort.html.tpl')}{/capture}
<script type="text/javascript">
  (function () {
    Vue.component('product-sort', {
      delimiters: ['%%', '%%'],
      template: "{$smarty.capture.template|escape:'javascript':'UTF-8'}",
      props: ['item'],
      data: function () {
        return {
          sorts: [
            {
              name: '{l s='Product: Newest first' mod='elasticsearch' js=1}',
              value: '{Elasticsearch::getAlias('date_add')|escape:'javascript':'UTF-8'}:desc'
            }, {
              name: '{l s='Price: Lowest first' mod='elasticsearch' js=1}',
              value: '{Elasticsearch::getAlias('price_tax_excl')|escape:'javascript':'UTF-8'}_group_{Context::getContext()->customer->id_default_group|intval}:asc'
            }, {
              name: '{l s='Price: Highest first' mod='elasticsearch' js=1}',
              value: '{Elasticsearch::getAlias('price_tax_excl')|escape:'javascript':'UTF-8'}_group_{Context::getContext()->customer->id_default_group|intval}:desc'
            }, {
              name: '{l s='Product Name: A to Z' mod='elasticsearch' js=1}',
              value: '{Elasticsearch::getAlias('name')|escape:'javascript':'UTF-8'}:asc'
            }, {
              name: '{l s='Product Name: Z to A' mod='elasticsearch' js=1}',
              value: '{Elasticsearch::getAlias('name')|escape:'javascript':'UTF-8'}:desc'
            }, {
              name: '{l s='Reference: Lowest first' mod='elasticsearch' js=1}',
              value: '{Elasticsearch::getAlias('reference')|escape:'javascript':'UTF-8'}:asc'
            }, {
              name: '{l s='Reference: Highest first' mod='elasticsearch' js=1}',
              value: '{Elasticsearch::getAlias('reference')|escape:'javascript':'UTF-8'}:desc'
            }
          ]
        }
      },
      computed: {
        selected: function () {
          return this.$store.state.sort;
        }
      },
      methods: {
        changeSort: function (event) {
          this.$store.commit('changeSort', event.target.value);
        }
      }
    });
  }());
</script>
