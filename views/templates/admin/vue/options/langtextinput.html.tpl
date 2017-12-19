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
    <span :class="description ? 'label-tooltip' : ''"
          :data-toggle="description ? 'tooltip' : ''"
          :data-html="description ? 'true' : ''"
          :title="description"
          :data-original-title="description"
    >
      %% displayName %%
    </span>
  </label>
  <div class="translatable-field col-lg-4">
    <div :class="languages.length > 1 ? 'col-lg-9' : 'col-lg-12'">
      <input type="text"
             :name="configKey"
             :id="configKey"
             :value="value"
             @keyup="setLangValue(idLang, $event)">
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
</div>
