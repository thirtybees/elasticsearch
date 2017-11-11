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
{capture name="template"}{include file=ElasticSearch::tpl('hook/vue/results/product-list-item.html.tpl')}{/capture}
<script type="text/javascript">
  (function () {
    Vue.component('product-list-item', {
      delimiters: ['%%', '%%'],
      template: "{$smarty.capture.template|escape:'javascript':'UTF-8'}",
      props: ['item'],
      data: function () {
        return {
          idGroup: {$idGroup|intval},
          currencyConversion: parseFloat({$currencyConversion|floatval}, 10)
        }
      },
      computed: {
        tax: function () {
          var taxes = {$taxes|json_encode};

          if (typeof this.item._source.id_tax_rules_group === 'undefined'
            || typeof taxes[this.item._source.id_tax_rules_group]) {
            return 1.000;
          }

          return taxes[this.item._source.id_tax_rules_group];
        },
        basePriceTaxIncl: function () {
          return parseFloat(this.item._source.price_tax_excl_group_0) * this.tax * this.currencyConversion;
        },
        priceTaxIncl: function () {
          return parseFloat(this.item._source['price_tax_excl_group_' + this.idGroup]) * this.tax * this.currencyConversion;
        }
      },
      methods: {
        formatCurrency: function (price) {
          return window.formatCurrency(price, window.currencyFormat, window.currencySign, window.currencyBlank);
        },
      }
    });
  }());
</script>
