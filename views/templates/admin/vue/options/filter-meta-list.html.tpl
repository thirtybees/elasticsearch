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
<div class="form-group">
  <label class="control-label col-lg-3">
    <span class="label-tooltip"
          data-toggle="tooltip"
          title=""
          data-original-title="{l s='You can drag and drop filters to adjust positions' mod='elasticsearch'}"
    >
      {l s='Fields' mod='elasticsearch'}
    </span>
  </label>
  <div class="col-lg-9">
    <section class="filter_panel">
      <header class="clearfix">
        <span class="badge badge-info">{l s='Total filters:' mod='elasticsearch'} %% _.filter(metas, function (item) { return item.visible; }).length %%</span>
        <span class="badge badge-success">{l s='Enabled filters:' mod='elasticsearch'} %% nbAggregatable %%</span>
      </header>
      <section class="filter_list">
        <ul class="list-unstyled sortable">
          <li v-for="(meta, index) in metas"
              v-if="meta.visible"
              :key="meta.code"
              class="filter_list_item"
              draggable="true"
              style="display: table;"
          >
            <span class="switch prestashop-switch col-lg-2 col-md-3 col-sm-4 col-xs-4"
                  @click="toggleMetaAggregatable(meta, $event)"
                  style="margin: 0 5px; pointer-events: all"
            >
              <input type="radio"
                     :id="'meta_aggregatable' + meta.code + '_on'"
                     :name="'meta_aggregatable' + meta.code"
                     :value="1"
                     :checked="meta.aggregatable"
              />
              <label :for="'meta_aggregatable_' + meta.code + '_on'">
                <p>{l s='Yes' mod='elasticsearch'}</p>
              </label>
              <input
                      type="radio"
                      :id="'meta_aggregatable_' + meta.code + '_off'"
                      :name="'meta_aggregatable_' + meta.code"
                      :value="0"
                      :checked="!meta.aggregatable"
              />
              <label :for="'meta_aggregatable_' + meta.code + '_off'">
                <p>{l s='No' mod='elasticsearch'}</p>
              </label>
                <a class="slide-button btn"></a>
            </span>
            <meta-badge :meta="meta" :id-lang="idLang" :config-key="configKey" style="max-width: 200px"></meta-badge>
            <div class="pull-right col-lg-8 col-md-4 col-sm-4">
              <div class="col-lg-6">
                <label class="control-label col-lg-4">{l s= 'Filter items limit:' mod='elasticsearch'}</label>
                <div class="col-lg-6">
                  <select @change="filterLimitChanged(meta, $event)" class="selectpicker">
                    <option value="0" :selected="parseInt(meta.result_limit, 10) === 0">{l s='No limit' mod='elasticsearch'}</option>
                    <option v-for="limit in [3, 4, 5, 10, 20]" :value.once="limit" :selected="meta.result_limit == limit">%% limit %%</option>
                  </select>
                </div>
              </div>
              <div class="col-lg-6">
                <label class="control-label col-lg-4">{l s='Filter style:' mod='elasticsearch'}</label>
                <div class="col-lg-8">
                  <select @change="filterStyleChanged(meta, $event)" class="selectpicker">
                    <option value="1" :selected="parseInt(meta.display_type) === 1">{l s='Checkbox' mod='elasticsearch'}</option>
                    {*<option value="2" :selected="parseInt(meta.display_type) === 2">{l s='Radio button' mod='elasticsearch'}</option>*}
                    {*<option value="3" :selected="parseInt(meta.display_type) === 3">{l s='Drop-down list' mod='elasticsearch'}</option>*}
                    <option value="4"
                            :selected.once="parseInt(meta.display_type) === 4"
                            v-if="meta.code === 'price_tax_excl'"
                    >
                      {l s='Slider' mod='elasticsearch'}
                    </option>
                    <option value="5"
                            :selected.once="parseInt(meta.display_type) === 5"
                            data-content="<span>{l s='Color' mod='elasticsearch'}</span> <img src='{$smarty.const.__PS_BASE_URI__|escape:'htmlall':'UTF-8'}img/admin/color_swatch.png' width='16' height='16'>"
                            v-if="!meta.elastic_types || _.includes(meta.elastic_types, 'text') || _.includes(meta.elastic_types, 'keyword')"
                    >
                      {l s='Color' mod='elasticsearch'}
                    </option>
                  </select>
                </div>
              </div>
              <div class="col-lg-6">
                <label class="control-label col-lg-4">{l s='Operator:' mod='elasticsearch'}</label>
                <div class="col-lg-8">
                  <select @change="operatorChanged(meta, $event)" class="selectpicker">
                    <option value="0" :selected="parseInt(meta.operator) === 0">{l s='AND (conjunctive)' mod='elasticsearch'}</option>
                    <option value="1" :selected="parseInt(meta.operator) === 1">{l s='OR (disjunctive)' mod='elasticsearch'}</option>
                  </select>
                </div>
              </div>
            </div>
          </li>
        </ul>
      </section>
    </section>
  </div>
</div>
