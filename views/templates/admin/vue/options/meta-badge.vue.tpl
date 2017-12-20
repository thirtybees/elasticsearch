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
{capture name="template"}{include file=ElasticSearch::tpl('admin/vue/options/meta-badge.html.tpl')}{/capture}
<script type="text/javascript">
  (function () {
    window.VueMetaBadge = {
      delimiters: ['%%', '%%'],
      template: "{$smarty.capture.template|escape:'javascript':'UTF-8'}",
      props: ['meta', 'idLang', 'configKey'],
      methods: {
        isDuplicate: function () {
          var self = this;
          return _.size(_.filter(_.map(this.$store.state.config[this.configKey], function (item) { return item.alias; }), function (value) { return value === self.meta.alias; })) > 1;
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
        updateAlias: function () {
          if (!this.configKey) {
            return;
          }

          var self = this;
          swal({
            title: 'Change alias',
            content: {
              element: 'input',
              attributes: {
                placeholder: this.meta.alias,
                type: 'text',
              },
            },
            buttons: {
              cancel: true,
              confirm: true
            },
            closeOnClickOutside: false,
          })
            .then(
              function (inputValue) {
                console.log(inputValue);
                if (inputValue == null) {
                  return false;
                }

                if (inputValue === '') {
                  window.showErrorMessage('{l s='You need to write something!' mod='elasticsearch' js=1}');
                  return false;
                }

                self.$store.commit('setMetaAlias', {
                  configKey: self.configKey,
                  code: self.meta.code,
                  value: inputValue
                });
              });
        }
      }
    };
  }());
</script>
