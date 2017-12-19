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
<div class="panel panel-default">
  <h3><i class="icon icon-plug"></i> {l s='Connection' mod='elasticsearch'}</h3>
  <div class="form-horizontal form-wrapper">
    <toggle display-name="{l s='Use an ajax proxy' mod='elasticsearch' js=1}" config-key="{Elasticsearch::PROXY}"></toggle>
    <server-list display-name="{l s='Server list' mod='elasticsearch' js=1}" config-key="{Elasticsearch::SERVERS}"></server-list>
  </div>
  <div class="panel-footer">
    <button type="submit" class="btn btn-default pull-right ajax-save-btn" :disabled="!canSubmit"
            @click="submitSettings">
      <i class="process-icon-save"></i> {l s='Save and stay' mod='elasticseach'}
    </button>
  </div>
</div>
