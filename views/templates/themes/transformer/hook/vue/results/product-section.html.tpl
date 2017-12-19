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
        <span v-if="parseInt(total, 10) === 1" class="heading-counter">{l s='There is' mod='elasticsearch'} %% total %% {l s='product.' mod='elasticsearch'}</span>
        <span v-else class="heading-counter">{l s='There are' mod='elasticsearch'} %% total %% {l s='products.' mod='elasticsearch'}</span>
      </span>
  </h2>
  <div class="content_sortPagiBar clearfix">
    <div class="top-pagination-content form-inline clearfix" v-if="!infiniteScroll">
      <product-count :limit="limit" :offset="offset" :total="total"></product-count>
    </div>

    <div class="form-inline sortPagiBar clearfix">
      <show-all></show-all>&nbsp;&nbsp;&nbsp;
      <product-sort style="margin-right: 10px"></product-sort>

      <div class="js-per-page form-group" v-if="!infiniteScroll">
        <label for="nb_item">{l s='Items per page:' mod='elasticsearch'}</label>
        <select @input="itemsPerPageHandler" class="form-control" style="width: 100px">
          <option v-for="itemsPerPage in itemsPerPageOptions"
                  :value.once="itemsPerPage"
                  :selected="itemsPerPage === limit"
                  :key="itemsPerPage"
          >%% itemsPerPage %%</option>
        </select>
      </div>

      <ul class="display hidden-xs">
        <li :class="'grid ' + (layoutType === 'grid' ? 'selected' : '')">
          <a @click="setLayoutType('grid')" rel="nofollow" style="cursor: pointer" title="{l s='Grid' mod='elasticsearch'}"></a>
        </li>
        <li :class="'list ' + (layoutType === 'list' ? 'selected' : '')">
          <a @click="setLayoutType('list')" rel="nofollow" style="cursor: pointer" title="{l s='List' mod='elasticsearch'}"></a>
        </li>
      </ul>
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

  {if $page_name == 'category' || $page_name == 'prices-drop' || $page_name == 'best-sales' || $page_name == 'manufacturer' || $page_name == 'supplier' || $page_name == 'new-products' || $page_name == 'search'}
    {if isset($HOOK_RIGHT_COLUMN) || isset($HOOK_LEFT_COLUMN) }
      {assign var='st_columns_nbr' value=1}
      {if isset($HOOK_LEFT_COLUMN) && $HOOK_LEFT_COLUMN|trim}{$st_columns_nbr=$st_columns_nbr+1}{/if}
      {if isset($HOOK_RIGHT_COLUMN) && $HOOK_RIGHT_COLUMN|trim}{$st_columns_nbr=$st_columns_nbr+1}{/if}
      {hook h='displayAnywhere' function='setColumnsNbr' columns_nbr=$st_columns_nbr page_name=$page_name mod='stthemeeditor' caller='stthemeeditor'}
      {capture name="st_columns_nbr"}{$st_columns_nbr}{/capture}
    {/if}
  {/if}

  {if isset($products) && $products}
    {capture name="home_default_width"}{getWidthSize type='home_default'}{/capture}
    {capture name="home_default_height"}{getHeightSize type='home_default'}{/capture}
    {capture name="display_sd"}{if isset($display_sd) && $display_sd} display_sd {elseif !isset($display_sd) && Configuration::get('STSN_SHOW_SHORT_DESC_ON_GRID')} display_sd {/if}{/capture}
  {/if}
  {assign var='for_w' value='category'}
  {if isset($for_f) && $for_f}
    {$for_w=$for_f}
  {/if}


  {capture name="display_color_list"}{if $for_w!='category' || !Configuration::get('STSN_DISPLAY_COLOR_LIST')} hidden {/if}{/capture}

  {*define numbers of product per line in other page for desktop*}

  {capture name="nbItemsPerLineDesktop"}3{/capture}
  {capture name="nbItemsPerLine"}3{/capture}
  {capture name="nbItemsPerLineTablet"}4{/capture}
  {capture name="nbItemsPerLineMobile"}6{/capture}
  {capture name="nbItemsPerLinePortrait"}12{/capture}

  {if isset($image_type) && isset($image_types[$image_type])}
    {assign var='imageSize' value=$image_types[$image_type].name}
  {else}
    {assign var='imageSize' value='home_default'}
  {/if}

  {* Transformer stuff *}
  {capture name="isInstalledWishlist"}{hook h='displayAnywhere' function="isInstalledWishlist" mod='stthemeeditor' caller='stthemeeditor'}{/capture}
  {assign var='length_of_product_name' value=Configuration::get('STSN_LENGTH_OF_PRODUCT_NAME')}
  {assign var='discount_percentage' value=Configuration::get('STSN_DISCOUNT_PERCENTAGE')}
  {assign var='sold_out_style' value=Configuration::get('STSN_SOLD_OUT')}
  {assign var='st_yotpo_sart' value=Configuration::get('STSN_YOTPO_SART')}
  {assign var='st_yotpoAppkey' value=Configuration::get('yotpo_app_key')}
  {capture name="st_yotpoDomain"}{hook h='displayAnywhere' function="getYotpoDomain" mod='stthemeeditor' caller='stthemeeditor'}{/capture}
  {capture name="st_yotpoLanguage"}{hook h='displayAnywhere' function="getYotpoLanguage" mod='stthemeeditor' caller='stthemeeditor'}{/capture}
  {assign var='new_sticker' value=Configuration::get('STSN_NEW_STYLE')}
  {assign var='sale_sticker' value=Configuration::get('STSN_SALE_STYLE')}
  {assign var='pro_list_display_brand_name' value=Configuration::get('STSN_PRO_LIST_DISPLAY_BRAND_NAME')}
  {assign var='st_display_add_to_cart' value=Configuration::get('STSN_DISPLAY_ADD_TO_CART')}
  {assign var='use_view_more_instead' value=Configuration::get('STSN_USE_VIEW_MORE_INSTEAD')}
  {assign var='flyout_wishlist' value=Configuration::get('STSN_FLYOUT_WISHLIST')}
  {assign var='flyout_quickview' value=Configuration::get('STSN_FLYOUT_QUICKVIEW')}
  {assign var='flyout_comparison' value=Configuration::get('STSN_FLYOUT_COMPARISON')}
  {assign var='flyout_buttons' value=Configuration::get('STSN_FLYOUT_BUTTONS')}

{*
function display(view) {
  if (view == 'list') {
    var classnames = $('ul.product_list').removeClass('grid row').addClass('list').attr('data-classnames');
    $('.product_list > li').removeClass(classnames).addClass('col-xs-12 clearfix');
    $('.content_sortPagiBar .display').find('li.list').addClass('selected');
    $('.content_sortPagiBar .display').find('li.grid').removeClass('selected');
    $.totalStorage('display', 'list');
  } else {
    var classnames = $('ul.product_list').removeClass('list').addClass('grid row').attr('data-classnames');
    $('.product_list > li').removeClass('col-xs-12 clearfix').addClass(classnames);
    $('.content_sortPagiBar .display').find('li.grid').addClass('selected');
    $('.content_sortPagiBar .display').find('li.list').removeClass('selected');
    $.totalStorage('display', 'grid');
  }
}
*}

  <pagination :limit="limit" :offset="offset" :total="total"></pagination>
  <ul{if isset($id) && $id} id="{$id}"{/if} :class="'product_list row{if isset($class) && $class} {$class}{/if} ' + (layoutType === 'grid' ? 'grid' :'list')">
    <li v-for="(result, index) in results" :key.once="result._id"
        :class.once="'ajax_block_product ' + (layoutType === 'grid' ? 'col-xs-{$smarty.capture.nbItemsPerLineMobileS}' : 'col-xs-12 clearfix ') + (layoutType === 'grid' ? ' col-sm-{$smarty.capture.nbItemsPerLineTablet} col-md-{$smarty.capture.nbItemsPerLine} ' : 'col-xs-12') + (index % (results.length / {$smarty.capture.nbItemsPerLine|intval})  === 1 ? ' last-in-line' : '') + (index % (results.length / {$smarty.capture.nbItemsPerLine|intval}) === 0 ? ' first-in-line' : '') + (index % (results.length / {$smarty.capture.nbItemsPerLineTablet|intval})  === 1 ? ' last-item-of-tablet-line' : '') + (index % (results.length / {$smarty.capture.nbItemsPerLineTablet|intval}) === 0 ? ' first-item-of-tablet-line' : '') + (index % (results.length / {$smarty.capture.nbItemsPerLineMobile|intval})  === 1 ? ' last-item-of-mobile-line' : '') + (index % (results.length / {$smarty.capture.nbItemsPerLineMobile|intval}) === 0 ? ' first-item-of-mobile-line' : '') + (index > (results.length + {$smarty.capture.nbItemsPerLine|intval}) ? ' last-line' : '') + (index > (results.length + {$smarty.capture.nbItemsPerLineMobile|intval}) ? ' last-mobile-line' : '')"
    >
      <product-list-item :item="result"></product-list-item>
    </li>
  </ul>
  <pagination :limit="limit" :offset="offset" :total="total"></pagination>

  <div class="content_sortPagiBar clearfix" v-if="!infiniteScroll">
  <div class="bottom-pagination-content form-inline">
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
