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
        <span class="badge badge-info">{l s='Total fields:' mod='elasticsearch'} %% _.filter(metas, function (item) { return item.visible; }).length %%</span>
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
            <span class="col-lg-2">
              <meta-badge :meta="meta" id-lang="idLang"></meta-badge>
            </span>

            <div class="translatable-field col-lg-4">
              <div :class="languages.length > 1 ? 'col-lg-9' : 'col-lg-12'">
                <input type="text"
                       :id="'name_' + idLang"
                       :name="'name' + idLang"
                       class=""
                       :value="meta.name[idLang]"
                       required="required"
                       @keyup="updateMetaName(meta.code, idLang, $event)">
              </div>
              <div v-if="languages.length > 1" class="col-lg-2">
                <button type="button" class="btn btn-default dropdown-toggle" data-toggle="dropdown">
                  <span>%% _.find(languages, {ldelim}id_lang: idLang.toString(){rdelim}).iso_code %%</span>
                  <i class="icon-caret-down"></i>
                </button>
                <ul class="dropdown-menu">
                  <li v-for="language in languages">
                    <a @click="updateLanguage(language.id_lang, $event)" class="pointer">%% language.name %%</a>
                  </li>
                </ul>
              </div>
            </div>

            <div class="pull-right">
            <span>{l s='Field type:' mod='elasticsearch'} </span>
            <select @change="updateElasticType(meta.code, $event)" class="selectpicker col-lg-2" :disabled="meta.elastic_types ? meta.elastic_types.length <= 1 : true">
              <option v-for="elasticType in (meta.elastic_types ? _.sortBy(meta.elastic_types) : _.sortBy(elasticTypes))"
                      :value="elasticType"
                      :selected="meta.elastic_type === elasticType ? 'selected' : null"
                      :data-content.once="'<kbd>' + elasticType + '</kbd>'"
              >%% elasticType %%
              </option>
            </select>
            </div>
          </li>
        </ul>
      </section>
    </section>
  </div>
</div>
