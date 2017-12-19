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
{capture name="template"}{include file=ElasticSearch::tpl('admin/vue/options/search-meta-list.html.tpl')}{/capture}
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
    };

    window.VueSearchMetaList = {
      delimiters: ['%%', '%%'],
      template: "{$smarty.capture.template|escape:'javascript':'UTF-8'}",
      components: {
        MetaBadge: VueMetaBadge
      },
      props: ['displayName', 'configKey', 'description'],
      methods: {
        toggleSearchable: function (code) {
          this.$store.commit('toggleSearchable', {
            configKey: this.configKey,
            code: code
          });
        },
        incrementWeight: function (code) {
          this.$store.commit('incrementWeight', {
            configKey: this.configKey,
            code: code
          });
        },
        decrementWeight: function (code) {
          this.$store.commit('decrementWeight', {
            configKey: this.configKey,
            code: code
          });
        },
        setWeight: function (code, event) {
          this.$store.commit('setWeight', {
            configKey: this.configKey,
            code: code,
            targetWeight: event.target.value
          });
        },
        toggleMetaSearchable: debounce(function (meta, event) {
          this.$store.commit('setMetaSearchable', {
            configKey: this.configKey,
            code: meta.code,
            value: !meta.searchable
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
        elasticTypes: function () {
          return {$elastic_types|json_encode};
        },
        nbSearchable: function () {
          return _.sumBy(this.$store.state.config[this.configKey], function (i) {
            return i.searchable ? 1 : 0;
          });
        }
      }
    };
  }());
</script>
