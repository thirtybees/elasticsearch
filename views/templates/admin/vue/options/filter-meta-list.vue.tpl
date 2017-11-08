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
{capture name="template"}{include file=ElasticSearch::tpl('admin/vue/options/filter-meta-list.html.tpl')}{/capture}
<script type="text/javascript">
  (function () {
    function debounce(func, wait, immediate) {
      var timeout;
      return function() {
        var context = this, args = arguments;
        var later = function() {
          timeout = null;
          if (!immediate) func.apply(context, args);
        };
        var callNow = immediate && !timeout;
        clearTimeout(timeout);
        timeout = setTimeout(later, wait);
        if (callNow) func.apply(context, args);
      };
    }

    window.VueFilterMetaList = {
      delimiters: ['%%', '%%'],
      template: "{$smarty.capture.template|escape:'javascript':'UTF-8'}",
      components: {
        MetaBadge: VueMetaBadge
      },
      props: ['displayName', 'configKey', 'description'],
      mounted: function () {
        var self = this;
        this.$nextTick(function () {
          $('span[data-toggle="tooltip"]').tooltip();
          var $sortable = $('.sortable');
          $sortable.sortable({
            forcePlaceholderSize: true,
            start: function(event, ui) {
              ui.item.startPos = ui.item.index();
            },
            update: function (event, ui) {
              self.$store.commit('setNewMetaPosition', {
                configKey: self.configKey,
                from: ui.item.startPos,
                to: ui.item.index()
              });
            }
          });
        });
      },
      methods: {
        updateLanguage: function (idLang) {
          this.$store.commit('setIdLang', idLang);
        },
        updateMetaName: function (code, idLang, event) {
          this.$store.commit('setMetaName', {
            configKey: this.configKey,
            code: code,
            value: event.target.value,
            idLang: idLang
          });
        },
        filterLimitChanged: function (meta, event) {
          this.$store.commit('setMetaFilterLimit', {
            configKey: this.configKey,
            code: meta.code,
            value: event.target.value
          });
        },
        filterStyleChanged: function (meta, event) {
          this.$store.commit('setMetaFilterStyle', {
          configKey: this.configKey,
            code: meta.code,
            value: event.target.value
          });
        },
        operatorChanged: function (meta, event) {
          this.$store.commit('setMetaOperator', {
            configKey: this.configKey,
            code: meta.code,
            value: event.target.value
          });
        },
        toggleMetaAggregatable: debounce(function (meta, event) {
          this.$store.commit('setMetaAggregatable', {
            configKey: this.configKey,
            code: meta.code,
            value: !meta.aggregatable
          });

          // Regular switch events
          toggleDraftWarning(false);
          showOptions(true);
          showRedirectProductOptions(false);
        }, 10)
      },
      computed: {
        metas: function () {
          return this.$store.state.config[this.configKey];
        },
        idLang: function () {
          return this.$store.state.idLang;
        },
        languages: function () {
          return {$languages|json_encode};
        },
        nbAggregatable: function () {
          return _.sumBy(this.$store.state.config[this.configKey], function (i) {
            return i.aggregatable ? 1 : 0;
          });
        }
      },
      data: function () {
        return {
          checked: true
        };
      }
    };
  }());
</script>
