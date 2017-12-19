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
{capture name="template"}{include file=ElasticSearch::tpl('admin/vue/options/server-list.html.tpl')}{/capture}
<script type="text/javascript">
  (function () {
    window.VueOptionServerList = {
      delimiters: ['%%', '%%'],
      template: "{$smarty.capture.template|escape:'javascript':'UTF-8'}",
      props: ['displayName', 'configKey', 'description'],
      data: function () {
        return {
          serverDraft: {
            read: 1,
            write: 1,
            url: ''
          }
        };
      },
      computed: {
        servers: function servers() {
          return this.$store.state.config[this.configKey];
        },
        proxied: function proxied() {
          return !!this.$store.state.config['{ElasticSearch::PROXY}'];
        }
      },
      methods: {
        addServer: function addServer(event) {
          this.$store.state.config[this.configKey].push(this.serverDraft);
          this.serverDraft = {
            read: 1,
            write: 1,
            url: ''
          };

          this.$store.commit('checkConfigChange');
        },
        toggleDraftRead: function toggleDraftRead() {
          if (this.proxied) {
            return;
          }

          this.serverDraft.read = !this.serverDraft.read;
        },
        toggleDraftWrite: function toggleDraftWrite() {
          if (this.proxied) {
            return;
          }

          this.serverDraft.write = !this.serverDraft.write;
        },
        updateDraftUrl: function updateDraftUrl(event) {
          this.serverDraft.url = event.target.value;
        },
        toggleRead: function toggleRead(server, event) {
          if (this.proxied) {
            return;
          }

          var item = _.find(
            this.$store.state.config[this.configKey],
            {
              url: server.url
            }
          );
          item.read = !item.read;

          this.$store.commit('checkConfigChange');
        },
        toggleWrite: function toggleWrite(server, event) {
          if (this.proxied) {
            return;
          }

          var item = _.find(
            this.$store.state.config[this.configKey],
            {
              url: server.url
            }
          );
          item.write = !item.write;

          this.$store.commit('checkConfigChange');
        },
        updateUrl: function updateUrl(server, event) {
          var item = _.find(
            this.$store.state.config[this.configKey],
            {
              url: server.url
            }
          );
          item.url = event.target.value;

          this.$store.commit('checkConfigChange');
        },
        deleteServer: function deleteServer(server) {
          this.$store.state.config[this.configKey] = this.$store.state.config[this.configKey].filter(function (item) {
            return item.url != server.url;
          });

          this.$store.commit('checkConfigChange');
        }
      }
    };
  }());
</script>
