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
<div class="panel panel-default">
  <h3><i class="icon icon-search"></i> {l s='Search' mod='elasticsearch'}</h3>
  <div class="form-horizontal form-wrapper">
    <toggle display-name="{l s='Use a list as default product layout' mod='elasticsearch' js=1}"
            config-key="{Elasticsearch::PRODUCT_LIST}"
            description="{l s='Show a product list instead of a grid by default' mod='elasticsearch'}"
    ></toggle>
    <tax-selector display-name="{l s='Price slider tax rules group' mod='elasticsearch'}"
                  config-key="{Elasticsearch::DEFAULT_TAX_RULES_GROUP}"
                  help="{l s='Apply this tax rules group to the slider. Note that if you have mixed taxes in your store, the shown product selection might no longer be accurate.' mod='elasticsearch'}"></tax-selector>
  </div>
  <div class="panel-footer">
    <button type="submit" class="btn btn-default pull-right ajax-save-btn" :disabled="!canSubmit"
            @click="submitSettings">
      <i class="process-icon-save"></i> {l s='Save and stay' mod='elasticseach'}
    </button>
  </div>
</div>
