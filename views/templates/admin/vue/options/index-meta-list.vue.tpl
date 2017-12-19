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
{capture name="template"}{include file=ElasticSearch::tpl('admin/vue/options/index-meta-list.html.tpl')}{/capture}
<script type="text/javascript">
  (function () {
    window.VueIndexMetaList = {
      mounted: function () {
        $('[data-toggle="index-meta-list-tooltip"]').tooltip();
        $('.selectpicker').selectpicker({
          style: 'btn-default',
          showTick: true,
          tickIcon: 'icon icon-check',
          width: '140px'
        });
      },
      updated: function () {
        $('[data-toggle="index-meta-list-tooltip"]')
          .tooltip('fixTitle');
      },
      delimiters: ['%%', '%%'],
      template: "{$smarty.capture.template|escape:'javascript':'UTF-8'}",
      components: {
        MetaBadge: VueMetaBadge
      },
      props: ['displayName', 'configKey', 'description'],
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
        updateElasticType: function (code, event) {
          this.$store.commit('setMetaElasticType', {
            configKey: this.configKey,
            code: code,
            value: event.target.value
          });
        },
        getMetaTypeBadge: function (metaType) {
          switch (metaType) {
            case 'attribute':
              return 'danger';
            case 'feature':
              return 'warning';
            default:
              return 'info';
          }
        },
        getMetaType: function (metaType) {
          switch (metaType) {
            case 'attribute':
              return '{l s='attr.' mod='elasticsearch' js=1}';
            case 'feature':
              return '{l s='feat.' mod='elasticsearch' js=1}';
            default:
              return '{l s='prop.' mod='elasticsearch' js=1}';
          }
        },
        toggleMetaEnabled: _.debounce(function (meta, event) {
          this.$store.commit('setMetaEnabled', {
            configKey: this.configKey,
            code: meta.code,
            value: !meta.enabled
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
        }
      }
    };
  }());
</script>
