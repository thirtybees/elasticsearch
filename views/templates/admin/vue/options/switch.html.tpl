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
    <span :class="description ? 'label-tooltip' : ''"
          :data-toggle="description ? 'tooltip' : ''"
          :data-html="description ? 'true' : ''"
          :title="description"
          :data-original-title="description"
    >
      %% displayName %%
    </span>
  </label>
  <div class="col-lg-9">
    <span class="switch prestashop-switch fixed-width-lg">
      <input
              type="radio"
              :name="configKey"
              :id="configKey + '_on'"
              :value="0"
              :checked="checked"
              @click="setChecked(1)"
      />
      <label :for="configKey + '_on'">
        <p>{l s='Yes' mod='elasticsearch'}</p>
      </label>
      <input
              type="radio"
              :name="configKey"
              :id="configKey + '_off'"
              :value="0"
              :checked="!checked"
              @click="setChecked(0)"
      />
      <label :for="configKey + '_off'">
        <p>{l s='No' mod='elasticsearch'}</p>
      </label>
        <a class="slide-button btn"></a>
    </span>
  </div>
  <div v-if="help" class="col-lg-9 col-lg-offset-3">
    <div class="help-block" v-html="help"></div>
  </div>
</div>
