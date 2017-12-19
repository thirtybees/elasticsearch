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
<section v-if="query && total || fixedFilter && _.indexOf(['manufacturer', 'supplier', 'category', 'categories'], fixedFilter.aggregationCode) > -1">
  <h2 class="page-heading">
    <span v-if="query || fixedFilter && _.indexOf(['category', 'categories'], fixedFilter.aggregationCode) > -1">{l s='Products' mod='elasticsearch'}</span>
    <span v-else-if="fixedFilter.aggregationCode === 'manufacturer'">{l s='List of products by manufacturer' mod='elasticsearch'} <strong>%% fixedFilter.filterName %%</strong></span>
    <span v-else-if="fixedFilter.aggregationCode === 'supplier'">{l s='List of products by supplier:' mod='elasticsearch'} <strong>%% fixedFilter.filterName %%</strong></span>
    <span class="pull-right">
        <span v-if="parseInt(total, 10) === 1" class="heading-counter badge">{l s='There is' mod='elasticsearch'} %% total %% {l s='product.' mod='elasticsearch'}</span>
        <span v-else class="heading-counter badge">{l s='There are' mod='elasticsearch'} %% total %% {l s='products.' mod='elasticsearch'}</span>
      </span>
  </h2>
  <div class="content_sortPagiBar clearfix">
    <div class="form-inline sortPagiBar clearfix">
      <div id="product-list-switcher" class="form-group display">
        <label class="visible-xs">{l s='Display product list as:' mod='elasticsearch'}</label>
        <div class="view-and-count">
          <div class="display" aria-label="Product list display type">
            {*<li style="list-style-type: none" :class="layoutType === 'grid' ? 'selected' : ''">*}
              {*<a id="es-grid"*}
                   {*rel="nofollow"*}
                   {*@click="setLayoutType('grid')"*}
                   {*title="{l s='Grid' mod='elasticsearch'}"*}
                   {*style="cursor: pointer"*}
              {*>*}
                {*<i class="icon icon-th-large"></i>*}
                {*<span class="visible-xs">{l s='Grid' mod='elasticsearch'}</span>*}
              {*</a>*}
            {*</li>*}
            {*<li style="list-style-type: none" :class="layoutType === 'list' ? 'selected' : ''">*}
              {*<a id="es-list"*}
                   {*rel="nofollow"*}
                   {*@click="setLayoutType('list')"*}
                   {*title="{l s='List' mod='elasticsearch'}"*}
                   {*style="cursor: pointer"*}
              {*>*}
                {*<i class="icon icon-th-list"></i>*}
                {*<span class="visible-xs">{l s='List' mod='elasticsearch'}</span>*}
              {*</a>*}
            {*</li>*}
          </div>
        </div>
      </div>

      <product-sort></product-sort>

      <div class="js-per-page form-group" v-if="!infiniteScroll">
        <label for="nb_item">{l s='Items per page:' mod='elasticsearch'}</label>
        <select @input="itemsPerPageHandler" class="form-control">
          <option v-for="itemsPerPage in itemsPerPageOptions"
                  :value.once="itemsPerPage"
                  :selected="itemsPerPage === limit"
                  :key="itemsPerPage"
          >%% itemsPerPage %%</option>
        </select>
      </div>
    </div>

    <div class="top-pagination-content form-inline clearfix" v-if="!infiniteScroll">
      <pagination :limit="limit" :offset="offset" :total="total"></pagination>

      <show-all></show-all>

      <product-count :limit="limit" :offset="offset" :total="total"></product-count>
    </div>
    {* TODO: restore product comparison functionality *}
    {*<div class="form-group compare-form">*}
    {*<form method="post" action="https://thirtybees.example.com/products-comparison">*}
    {*<button type="submit" class="btn btn-success bt_compare bt_compare" disabled="disabled">*}
    {*<span>Compare (<strong class="total-compare-val">0</strong>) »</span>*}
    {*</button>*}
    {*<input type="hidden" name="compare_product_count" class="compare_product_count" value="0">*}
    {*<input type="hidden" name="compare_product_list" class="compare_product_list" value="">*}
    {*</form>*}
    {*</div>*}
  </div>

  {*define numbers of product per line in other page for desktop*}
  {capture name="nbItemsPerLineLarge"}{hook h='calculateGrid' size='large'}{/capture}
  {capture name="nbItemsPerLine"}{hook h='calculateGrid' size='medium'}{/capture}
  {capture name="nbItemsPerLineTablet"}{hook h='calculateGrid' size='small'}{/capture}
  {capture name="nbItemsPerLineMobile"}{hook h='calculateGrid' size='mediumsmall'}{/capture}
  {capture name="nbItemsPerLineMobileS"}{hook h='calculateGrid' size='xtrasmall'}{/capture}

  {*define numbers of product per line in other page for tablet*}
  {assign var='nbLi' value=$products|@count}
  {math equation="nbLi/nbItemsPerLine" nbLi=$nbLi nbItemsPerLine=$smarty.capture.nbItemsPerLine assign=nbLines}
  {math equation="nbLi/nbItemsPerLineTablet" nbLi=$nbLi nbItemsPerLineTablet=$smarty.capture.nbItemsPerLineTablet assign=nbLinesTablet}

  {if isset($image_type) && isset($image_types[$image_type])}
    {assign var='imageSize' value=$image_types[$image_type].name}
  {else}
    {assign var='imageSize' value='home_default'}
  {/if}


  {math equation="(total%perLine)" total=$smarty.foreach.products.total perLine=$smarty.capture.nbItemsPerLine assign=totModulo}
  {math equation="(total%perLineT)" total=$smarty.foreach.products.total perLineT=$smarty.capture.nbItemsPerLineTablet assign=totModuloTablet}
  {math equation="(total%perLineT)" total=$smarty.foreach.products.total perLineT=$smarty.capture.nbItemsPerLineMobile assign=totModuloMobile}
  {if $totModulo == 0}{assign var='totModulo' value=$smarty.capture.nbItemsPerLine}{/if}
  {if $totModuloTablet == 0}{assign var='totModuloTablet' value=$smarty.capture.nbItemsPerLineTablet}{/if}
  {if $totModuloMobile == 0}{assign var='totModuloMobile' value=$smarty.capture.nbItemsPerLineMobile}{/if}
  <ul{if isset($id) && $id} id="{$id}"{/if} class="product_list grid row{if isset($class) && $class} {$class}{/if}">
    <li v-for="(result, index) in results" :key.once="result._id"
        :class.once="'ajax_block_product col-xs-{$smarty.capture.nbItemsPerLineMobileS} col-ms-{$smarty.capture.nbItemsPerLineMobile} col-sm-{$smarty.capture.nbItemsPerLineTablet} col-md-{$smarty.capture.nbItemsPerLine} col-lg-{$smarty.capture.nbItemsPerLineLarge} ' + (index % (results.length / {$smarty.capture.nbItemsPerLine|intval})  === 1 ? ' last-in-line' : '') + (index % (results.length / {$smarty.capture.nbItemsPerLine|intval}) === 0 ? ' first-in-line' : '') + (index % (results.length / {$smarty.capture.nbItemsPerLineTablet|intval})  === 1 ? ' last-item-of-tablet-line' : '') + (index % (results.length / {$smarty.capture.nbItemsPerLineTablet|intval}) === 0 ? ' first-item-of-tablet-line' : '') + (index % (results.length / {$smarty.capture.nbItemsPerLineMobile|intval})  === 1 ? ' last-item-of-mobile-line' : '') + (index % (results.length / {$smarty.capture.nbItemsPerLineMobile|intval}) === 0 ? ' first-item-of-mobile-line' : '') + (index > (results.length + {$smarty.capture.nbItemsPerLine|intval}) ? ' last-line' : '') + (index > (results.length + {$smarty.capture.nbItemsPerLineMobile|intval}) ? ' last-mobile-line' : '')"
    >
      <product-list-item :item="result"></product-list-item>
    </li>
  </ul>

<div class="content_sortPagiBar" v-if="!infiniteScroll">
  <div class="bottom-pagination-content form-inline clearfix">
    <pagination :limit="limit" :offset="offset" :total="total"></pagination>
    <show-all></show-all>
    <product-count :limit="limit" :offset="offset" :total="total"></product-count>
  </div>
  {* TODO: restore compare functionality *}
    {*<div class="form-group compare-form">*}
    {*<form method="post" action="https://thirtybees.example.com/products-comparison">*}
    {*<button type="submit" class="btn btn-success bt_compare bt_compare" disabled="disabled">*}
    {*<span>Compare (<strong class="total-compare-val">0</strong>) »</span>*}
    {*</button>*}
    {*<input type="hidden" name="compare_product_count" class="compare_product_count" value="0">*}
    {*<input type="hidden" name="compare_product_list" class="compare_product_list" value="">*}
    {*</form>*}
    {*</div>*}
  </div>
  <infinite-loading @infinite="loadMoreProducts" v-if="infiniteScroll">
      <span slot="no-more">
        {l s='You\'ve reached the end of the list' mod='elasticsearch'}
      </span>
  </infinite-loading>
</section>
<section v-else-if="!query">
  <div class="alert alert-warning">
    {l s='Please enter a search keyword' mod='elasticsearch'}
  </div>
</section>
<section v-else>
  <div class="alert alert-warning">
    {l s='No results found' mod='elasticsearch'}
  </div>
</section>
