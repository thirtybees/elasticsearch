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
<div class="form-horizontal">
  <div class="panel">
    <div class="panel-heading">
      <i class="icon-cogs"></i> {l s='Settings' mod='elasticsearch'}
    </div>
    <div class="form-wrapper">
      <number-input :display-name="'{l s='Number of shards' mod='elasticsearch' js=1}'"
                    config-key="{Elasticsearch::SHARDS}"
                    max-width="100"
      ></number-input>
      <number-input :display-name="'{l s='Number of replicas' mod='elasticsearch' js=1}'"
                    config-key="{Elasticsearch::REPLICAS}"
                    max-width="100"
      ></number-input>
      <text-input :display-name="'{l s='Index prefix' mod='elasticsearch' js=1}'"
                  config-key="{Elasticsearch::INDEX_PREFIX}"
                  max-width="200"
      ></text-input>
      <lang-text-input :display-name="'{l s='Stop words' mod='elasticsearch' js=1}'"
                       config-key="{Elasticsearch::STOP_WORDS}"
                       description="{l s='Separate the stop words by a comma. _english_ represents the array with common stop words in English' mod='elasticsearch'}"
      ></lang-text-input>
      <toggle :display-name="'{l s='Enable logging' mod='elasticsearch' js=1}'"
              config-key="{Elasticsearch::LOGGING_ENABLED}"
      ></toggle>
    </div>
    <div class="panel-footer">
      <button type="submit"
              class="btn btn-default pull-right ajax-save-btn"
              :disabled="!canSubmit"
              @click="submitSettings">
        <i class="process-icon-save"></i> {l s='Save and stay' mod='elasticseach'}
      </button>
    </div>
  </div>
</div>
