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
<div class="form-group product-count">
  <p class="form-control-static">
    {l s='Showing' mod='elasticsearch'} %% _.min([offset + 1, total.value]) %% - %% _.min([page * limit, total.value]) %% {l s='of' mod='elasticsearch'} %% total.value %% <span v-if="parseInt(total.value, 10) === 1">{l s='item' mod='elasticsearch'}</span><span v-else>{l s='items' mod='elasticsearch'}</span>
  </p>
</div>
