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
<div class="form-group clearfix">
  <ul class="pagination" style="cursor: pointer">
    <li :disabled="page == 1"
        :class="(page == 1) ? 'disabled ' : '' + 'pagination_previous'"
        title="{l s='First' mod='elasticsearch'}"
    >
      <a @click="setPage(1)">
        <span class="icon icon-angle-double-left"></span>
      </a>
    </li>
    <li :disabled="page == 1"
        :class="(page == 1) ? 'disabled ' : '' + 'pagination_previous'"
        title="{l s='Previous' mod='elasticsearch'}"
    >
      <a @click="setPage(page - 1)">
        <span class="icon icon-angle-left"></span>
      </a>
    </li>
    <li v-for="numberToShow in numbersToShow" :class="(page == numberToShow) ? 'active current' : ''">
      <a @click="setPage(numberToShow)">
        <span>%% numberToShow %%</span>
      </a>
    </li>
    <li :disabled="page == nbPages" :class="(page == nbPages) ? 'disabled' : '' + 'pagination_next'" title="Next">
      <a rel="next" @click="setPage(page + 1)">
        <span class="icon icon-angle-right"></span>
      </a>
    </li>
    <li :disabled="page == nbPages" :class="(page == nbPages) ? 'disabled' : '' + 'pagination_next'" title="Next">
      <a rel="next" @click="setPage(nbPages)">
        <span class="icon icon-angle-double-right"></span>
      </a>
    </li>
  </ul>
</div>
