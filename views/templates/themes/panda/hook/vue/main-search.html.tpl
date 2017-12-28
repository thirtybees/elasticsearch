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
<div id="search_block_top" class=" clearfix">
  <form id="es-searchbox" method="get" action="{$link->getModuleLink('elasticsearch', 'search', [], true)|escape:'htmlall':'UTF-8'}">
    <div :class="'searchbox_inner ' + (focused ? 'active' : '')">
      <input type="hidden" name="controller" value="search">
      <input type="hidden" name="orderby" value="position">
      <input type="hidden" name="orderway" value="desc">
      <input class="search_query form-control ac_input"
             type="text"
             id="search_query_top"
             name="search_query"
             placeholder="{l s='Search' mod='elasticsearch'}"
             spellcheck="false"
             required
             aria-label="{l s='Search our site' mod='elasticsearch'}"
             :value="query"
             @input="queryChangedHandler"
             @keydown.enter="submitHandler"
             @keydown.up="suggestionUpHandler"
             @keydown.down="suggestionDownHandler"
             @focus="focusHandler"
      >
      <div class="hidden"
           id="more_prod_string">
        {l s='More products' mod='elasticsearch'} »
      </div>
      <a title="Search"
         rel="nofollow"
         id="submit_searchbox"
         class="submit_searchbox icon_wrap"
         style="cursor: pointer; margin-left: -10px"
         @click="submitHandler"
      >
        <i class="icon-search-1 icon-0x"></i><span class="icon_text">{l s='Search' mod='elasticsearch'}</span></a>
    </div>
  </form>
  <elasticsearch-autocomplete v-if="{if Configuration::get(Elasticsearch::AUTOCOMPLETE)}true{else}false{/if}"
                              id="elasticsearch-autocomplete"
                              :results="suggestions"
                              :selected="selected"
  ></elasticsearch-autocomplete>

</div>

