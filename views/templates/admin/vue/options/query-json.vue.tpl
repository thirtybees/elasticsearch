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
{capture name="template"}{include file=ElasticSearch::tpl('admin/vue/options/query-json.html.tpl')}{/capture}
<script type="text/javascript">
  (function () {
    window.VueQueryJson = {
      delimiters: ['%%', '%%'],
      template: "{$smarty.capture.template|escape:'javascript':'UTF-8'}",
      props: ['displayName', 'configKey', 'description'],
      mounted: function () {
        this.$nextTick(function () {
          var self = this;
          var editor = ace.edit('ace' + this.configKey);
          editor.setTheme('ace/theme/xcode');
          editor.getSession().setMode('ace/mode/javascript');
          editor.setOptions({
            fontSize: 14,
            minLines: 20,
            maxLines: 100,
            showPrintMargin: true
          });
          editor.on('change', function () {
            self.$store.commit('setConfig', {
              key: self.configKey,
              value: editor.getValue()
            });
          });
          // Disable error checking
          editor.getSession().setUseWorker(false);
        });
      },
      computed: {
        queryJson: function () {
          return this.$store.state.config[this.configKey];
        }
      }
    };
  }());
</script>
