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
    function checkConfigChange(state) {
      state.configChanged = !_.isEqual(state.config, JSON.parse(state.initialConfig));
    }

    window.config = new Vuex.Store({
      state: {
        config: {$config|json_encode},
        configChanged: false,
        initialConfig: JSON.stringify({$config|json_encode}),
        tab: window.location.hash.substr(5) || '{$initialTab|escape:'javascript':'UTF-8'}',
        status: {$status|json_encode},
        elasticsearchVersion: '{l s='Loading...' mod='elasticsearch' js=1}',
        elasticErrors: null,
        indexing: false,
        cancelingIndexing: false,
        saving: false,
        idLang: {Context::getContext()->language->id|intval}
      },
      mutations: {
        setConfig: function (state, props) {
          state.config[props.key] = props.value;

          checkConfigChange(state);
        },
        setInitialConfig: function (state, config) {
          state.initialConfig = config;

          checkConfigChange(state);
        },
        setTab: function (state, tabKey) {
          state.tab = tabKey;
        },
        setElasticsearchVersion: function (state, version) {
          state.elasticsearchVersion = version;
        },
        setElasticErrors: function (state, errors) {
          state.elasticErrors = errors;
        },
        setIndexing: function (state, indexing) {
          state.indexing = indexing;
        },
        setCancelingIndexing: function (state, cancelingIndexing) {
          state.cancelingIndexing = cancelingIndexing;
        },
        setSaving: function (state, saving) {
          state.saving = saving;
        },
        setIndexingStatus: function (state, status) {
          state.status = status;
        },
        setIdLang: function (state, idLang) {
          state.idLang = idLang;
        },
        setMetaName: function (state, payload) {
          var target = _.find(state.config[payload.configKey], ['code', payload.code]);
          if (typeof target !== 'undefined') {
            target['name'][payload.idLang] = payload.value;
          }

          checkConfigChange(state);
        },
        setMetaFilterLimit: function (state, payload) {
          var target = _.find(state.config[payload.configKey], ['code', payload.code]);
          if (typeof target !== 'undefined') {
            target.result_limit = payload.value;
          }

          checkConfigChange(state);
        },
        setMetaFilterStyle: function (state, payload) {
          var target = _.find(state.config[payload.configKey], ['code', payload.code]);
          if (typeof target !== 'undefined') {
            target.display_type = payload.value;
          }

          checkConfigChange(state);
        },
        setMetaOperator: function (state, payload) {
          var target = _.find(state.config[payload.configKey], ['code', payload.code]);
          if (typeof target !== 'undefined') {
            target.operator = payload.value;
          }

          checkConfigChange(state);
        },
        setNewMetaPosition: function (state, payload) {
          // Edit a clone of the array (directly will cause unnecessary UI updates)
          var array = _.cloneDeep(state.config[payload.configKey]);
          array.splice(payload.to, 0, array.splice(payload.from, 1)[0]);

          // Trigger an update by setting the clone
          state.config[payload.configKey] = array;

          checkConfigChange(state);
        },
        setMetaElasticType: function (state, payload) {
          var target = _.find(state.config[payload.configKey], ['code', payload.code]);
          if (typeof target !== 'undefined') {
            target['elastic_type'] = payload.value;
          }

          checkConfigChange(state);
        },
        setMetaAggregatable: function(state, payload) {
          var target = _.find(state.config[payload.configKey], ['code', payload.code]);
          if (typeof target !== 'undefined') {
            target.aggregatable = payload.value
          }

          checkConfigChange(state);
        },
        setMetaSearchable: function (state, payload) {
          var target = _.find(state.config[payload.configKey], ['code', payload.code]);
          if (typeof target !== 'undefined') {
            target.searchable = payload.value;
          }

          checkConfigChange(state);
        },
        incrementWeight: function (state, payload) {
          var target = _.find(state.config[payload.configKey], ['code', payload.code]);
          if (typeof target !== 'undefined') {
            target.weight += 1.0000;
          }

          checkConfigChange(state);
        },
        decrementWeight: function (state, payload) {
          var target = _.find(state.config[payload.configKey], ['code', payload.code]);
          if (typeof target !== 'undefined') {
            var targetWeight = target.weight - 1.0000;
            if (targetWeight < 0.1) {
              targetWeight = 0.1;
            }

            target.weight = targetWeight;
          }

          checkConfigChange(state);
        },
        setWeight: function (state, payload) {
          var target = _.find(state.config[payload.configKey], ['code', payload.code]);
          if (typeof target !== 'undefined') {
            target.weight = payload.targetWeight;
          }

          checkConfigChange(state);
        },
        setTextValue: function (state, payload) {
          state.config[payload.code] = payload.value;

          checkConfigChange(state);

        },
        checkConfigChange: function (state) {
          checkConfigChange(state);
        }
      }
    });
  }());
</script>
