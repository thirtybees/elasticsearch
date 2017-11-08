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
<script type="text/javascript">
  (function () {
    {* If dev mode, enable Vue dev mode as well *}
    {*{if $smarty.const._PS_MODE_DEV_}Vue.config.devtools = true;{/if}*}
    {* FIXME: hard-coded to true *}
    Vue.config.devtools = true;

    var ajaxAttempts = 3;

    function indexProducts(self) {
      $.ajax({
        url: window.elasticAjaxUrl + '&ajax=1&action=indexRemaining',
        method: 'GET',
        dataType: 'json',
        success: function (response) {
          if (typeof response !== 'undefined'
            && typeof response.indexed !== 'undefined'
            && typeof response.total !== 'undefined'
          ) {
            self.$store.commit('setIndexingStatus', {
              indexed: response.indexed,
              total: response.total
            });
          } else {
            swal({
              title: '{l s='Error!' mod='elasticsearch' js=1}',
              text: '{l s='Unable to connect with the Elasticsearch server. Has the connection been configured?' mod='elasticsearch' js=1}',
              icon: 'error'
            });
          }
        },
        complete: function (xhr) {
          if ((parseInt(xhr.status, 10) !== 200 && ajaxAttempts > 0)
            || (!self.$store.state.cancelingIndexing && xhr.responseJSON && xhr.responseJSON.indexed !== xhr.responseJSON.total)
          ) {
            if (parseInt(xhr.status, 10) !== 200) {
              // Decrement if failure...
              ajaxAttempts -= 1;
            } else {
              // ...reset otherwise
              ajaxAttempts = 3;
            }

            indexProducts(self);
          } else {
            if (ajaxAttempts <= 0) {
              swal({
                title: '{l s='Error!' mod='elasticsearch' js=1}',
                text: '{l s='Error while contacting the webserver. Please check your server logs for errors and correct them if necessary.' mod='elasticsearch' js=1}',
                icon: 'error'
              });
            }

            self.$store.commit('setIndexing', false);
            self.$store.commit('setCancelingIndexing', false);
          }
        }
      });
    }

    new Vue({
      created: function () {
        var self = this;
        $.ajax({
          url: window.elasticAjaxUrl + '&ajax=1&action=getElasticsearchVersion',
          method: 'GET',
          dataType: 'json',
          success: function (response) {
            if (response && response.version) {
              self.$store.commit('setElasticsearchVersion', response.version);
            }
          }
        });
      },
      delimiters: ['%%', '%%'],
      el: '#es-module-page',
      store: window.config,
      components: {
        Toggle: VueOptionSwitch,
        TextInput: VueTextInput,
        NumberInput: VueNumberInput,
        ServerList: VueOptionServerList,
        MetaBadge: VueMetaBadge,
        IndexMetaList: VueIndexMetaList,
        SearchMetaList: VueSearchMetaList,
        FilterMetaList: VueFilterMetaList,
        QueryJson: VueQueryJson
      },
      computed: {
        currentTab: function () {
          return this.$store.state.tab;
        },
        tabs: function () {
          return {$tabs|json_encode};
        },
        canSubmit: function () {
          return this.$store.state.configChanged && !this.loading;
        },
        productsIndexed: function () {
          return this.$store.state.status.indexed;
        },
        productsToIndex: function () {
          return this.$store.state.status.total;
        },
        elasticsearchVersion: function () {
          return this.$store.state.elasticsearchVersion;
        },
        indexing: function () {
          return this.$store.state.indexing;
        },
        cancelingIndexing: function () {
          return this.$store.state.cancelingIndexing;
        },
        saving: function () {
          return this.$store.state.saving;
        }
      },
      data: function data() {
        return {
          totalProducts: {$totalProducts|intval},
          languages: {$languages|json_encode}
        };
      },
      methods: {
        setTab: function (tabKey) {
          this.$store.commit('setTab', tabKey);
        },
        setLoading: function (loading) {
          $('.ajax-save-btn').each(function (index, elem) {
            if (loading) {
              $i = $(elem).find('i');
              $i.removeClass('process-icon-save').addClass('process-icon-loading');
              $(elem).attr('disabled', 'disabled');
            } else {
              $i = $(elem).find('i');
              $i.addClass('process-icon-save').removeClass('process-icon-loading');
              $(elem).removeAttr('disabled');
            }
          });
        },
        startIndexing: function () {
          this.$store.commit('setIndexing', true);

          // Reset the amount of ajax attempts
          ajaxAttempts = 3;
          indexProducts(this);
        },
        cancelIndexing: function () {
          this.$store.commit('setCancelingIndexing', true);
        },
        eraseIndex: function () {
          var self = this;
          $.ajax({
            url: window.elasticAjaxUrl + '&ajax=1&action=eraseIndex',
            method: 'GET',
            dataType: "json",
            success: function (response) {
              if (typeof response !== 'undefined'
                && typeof response.indexed !== 'undefined'
                && typeof response.total !== 'undefined'
              ) {
                self.$store.commit('setIndexingStatus', {
                  indexed: response.indexed,
                  total: response.total
                });
              }
            }
          });
        },
        submitSettings: function (event) {
          if (this.$store.state.saving) {
            return;
          }

          this.$store.commit('setSaving', true);

          var self = this;
          $.ajax({
            url: window.elasticAjaxUrl + '&ajax=1&action=saveSettings',
            method: 'POST',
            contentType: 'application/json; charset=utf-8',
            dataType: 'json',
            data: JSON.stringify(this.$store.state.config),
            success: function () {
              self.$store.commit('setInitialConfig', JSON.stringify(self.$store.state.config));
              window.showSuccessMessage('{l s='Settings have been successfully updated' mod='elasticsearch' js=1}');
            },
            complete: function () {
              self.$store.commit('setSaving', false);
            }
          });
        }
      }
    })
  }());
</script>
