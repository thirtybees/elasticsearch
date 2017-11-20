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
<div class="product-container">
  <div class="pro_outer_box">
    <div class="pro_first_box">
      <a class="product_img_link" :href.once="item._source.link"
         :title.once="item._source.name">
        <img class="replace-2x img-responsive front-image"
             :src.once="'//' + item._source.image_link_large"
             :alt.once="item._source.name"
             :title.once="item._source.name"
        />
        <span v-if="{if $new_sticker != 2}true{else}false{/if} && item._source.new" class="new"><i>{l s='New' mod='elasticsearch'}</i></span>
          <span v-if="item._source.on_sale || basePriceTaxIncl > priceTaxIncl" class="on_sale"><i>{l s='Sale'}</i></span>
          <span v-if="{if !$PS_CATALOG_MODE && !isset($restricted_country_mode)}true{else}false{/if} && (item._source.show_price || item._source.available_for_order) && basePriceTaxIncl > priceTaxIncl" class="sale_percentage_sticker img-circle"> %% discountPercentage%%%<br/>{l s='Off' mod='elasticsearch'}</span>
          <span v-if="{if  !isset($restricted_country_mode) && !$PS_CATALOG_MODE && $PS_STOCK_MANAGEMENT}true{else}false{/if} && (item._source.show_price || item._source.available_for_order)">
            <span v-if="!item._source.in_stock && !item._source.allow_oosp" class="sold_out">{l s='- Sold out -'}</span>
            <span v-if="!item._source.in_stock" class="sold_out">{l s='- Sold out -' mod='elasticsearch'}</span>
          </span>
      </a>
      {*{assign var="fly_i" value=0}*}
      {*{if !$st_display_add_to_cart && trim($smarty.capture.pro_a_cart)}{assign var="fly_i" value=$fly_i+1}{/if}*}
      {*{if trim($smarty.capture.pro_a_compare)}{assign var="fly_i" value=$fly_i+1}{/if}*}
      {*{if trim($smarty.capture.pro_quick_view)}{assign var="fly_i" value=$fly_i+1}{/if}*}
      {*{if trim($smarty.capture.pro_a_wishlist)}{assign var="fly_i" value=$fly_i+1}{/if}*}
      <div class="hover_fly {if Configuration::get('STSN_FLYOUT_BUTTONS')} hover_fly_static{/if} + fly_2 clearfix">
        {if isset($use_view_more_instead) && $use_view_more_instead}
          <a class="view_button btn btn-default" :href.once="item._source.link" title="{l s='View more' mod='elasticsearch'}"
             rel="nofollow">
            <div><i class="icon-eye-2 icon-0x icon_btn icon-mar-lr2"></i><span>{l s='View more' mod='elasticsearch'}</span></div>
          </a>
        {else}
          <a v-if="item._source.available_for_order && {if !isset($restricted_country_mode) && !$PS_CATALOG_MODE}true{else}false{/if} && !item._source.customization_required && (item._source.allow_oosp || item._source.in_stock)"
             class="ajax_add_to_cart_button btn btn-default btn_primary"
             :href.once="item._source.link"
             rel="nofollow"
             title="{l s='Add to cart' mod='elasticsearch'}"
             :data-id-product.once="item._id"
             :data-minimal_quantity.once="item._source.minimal_quantity ? item._source.minimal_quantity : 1">
            <div><i class="icon-basket icon-0x icon_btn icon-mar-lr2"></i><span>{l s='Add to cart' mod='elasticsearch'}</span></div>
          </a>
          <a v-else
             class="view_button btn btn-default"
             :href.once="item._source.link"
             title="{l s='View' mod='elasticsearch'}"
             rel="nofollow">
            <div><i class="icon-eye-2 icon-0x icon_btn icon-mar-lr2"></i><span>{l s='View' mod='elasticsearch'}</span></div>
          </a>
        {/if}
        {if !$flyout_quickview && isset($quick_view) && $quick_view}
          <a class="quick-view"
             :href.once="item._source.link"
             :rel.once="item._source.link"
             title="{l s='Quick view' mod='elasticsearch'}">
            <div><i class="icon-search-1 icon-0x icon_btn icon-mar-lr2"></i><span>{l s='Quick view' mod='elasticsearch'}</span></div>
          </a>
        {/if}
        {*{if !$flyout_comparison && isset($comparator_max_item) && $comparator_max_item}*}
          {*<a class="add_to_compare"*}
             {*:href.once="item._source.link"*}
             {*:data-id-product.once="item._id"*}
             {*rel="nofollow"*}
             {*:data-product-cover.once="'//' + item._source.image_link_large"*}
             {*:data-product-name.once="item._source.name"*}
             {*title="{l s='Add to compare' mod='elasticsearch'}"*}
          {*>*}
            {*<div><i class="icon-ajust icon-0x icon_btn icon-mar-lr2"></i><span>{l s='Add to compare' mod='elasticsearch'}</span></div>*}
          {*</a>*}
        {*{/if}*}
        {* TODO: restore wishlisht functionality *}
        {*{if !$flyout_wishlist && $smarty.capture.isInstalledWishlist}*}
          {*<a :class.once="'addToWishlist wishlistProd_' + item._id" style="cursor: pointer" rel="nofollow"*}
             {*:data-pid.once="item._id"*}
             {*:onclick.once="'WishlistCart(\'wishlist_block_list\', \'add\', \'' + item._id + '\', false, 1, this); return false;'">*}
            {*<div><i class="icon-heart icon-0x icon_btn icon-mar-lr2"></i><span>{l s='Add to Wishlist' mod='elasticsearch'}</span></div>*}
          {*</a>*}
        {*{/if}*}
      </div>
    </div>
    <div class="pro_second_box">
      <h5 itemprop="name"
          class="s_title_block{if $length_of_product_name} nohidden{/if}">
        {* {if isset($product.pack_quantity) && $product.pack_quantity}{$product.pack_quantity|intval|cat:' x '}{/if} *}
        <a class="product-name"
           :href.once="item._source.link"
           title="item._source.name"
           >
          %% item._source.name %%
        </a>
      </h5>
      {* TODO: restore dynamic hooks *}
      {*{hook h='displayProductListReviews' product=$product}*}
      {if $pro_list_display_brand_name}
        <p v-if="item._source.manufacturer" class="pro_list_manufacturer">%% item._source.manufacturer %%</p>
      {/if}
      <div class="price_container">
        {* TODO: restore dynamic hooks *}
        <span v-if="item._source.show_price"
              itemprop="price"
              class="price product-price"
        >
          %% formatCurrency(priceTaxIncl) %%
        </span>
        {* TODO: restore dynamic hooks *}
        {*{hook h="displayProductPriceBlock" product=$product type="old_price"}*}
        <span v-if="basePriceTaxIncl > priceTaxIncl" class="old-price product-price">%% formatCurrency(basePriceTaxIncl) %%</span>
        <span class="sale_percentage">
          <i class="icon-tag"></i>-%% discountPercentage %%%
        </span>
        {* TODO: restore dynamic hooks *}
        {*{hook h="displayProductPriceBlock" product=$product type="price"}*}
        {*{hook h="displayProductPriceBlock" product=$product type="unit_price"}*}
        {*{hook h="displayProductPriceBlock" product=$product type='after_price'}*}
      </div>
      <div v-if="item._source.online_only" class="mar_b6 product_online_only_flags">
        <span class="online_only sm_lable">
          {l s='Online only' mod='elasticsearch'}
        </span>
      </div>
      <div v-if="basePriceTaxIncl > priceTaxIncl || item._source.on_sale" class="mar_b6 product_discount_flags">
        <span class="discount sm_lable">{l s='Reduced price!' mod='elasticsearch'}</span>
      </div>
      <stock-badge :item.once="item"></stock-badge>
      <div v-if="item._source.color_list" class="color-list-container {$smarty.capture.display_color_list|escape:'htmlall':'UTF-8'}" v-html="item._source.color_list"></div>
      {* TODO: restore hooks *}
      {*{if $for_w!='hometab'}{hook h='displayAnywhere' function="getProductRatingAverage" id_product=$product.id_product mod='stthemeeditor' caller='stthemeeditor'}{/if}*}
      {*{if $for_w=='category'}{hook h='displayAnywhere' function="getProductAttributes" id_product=$product.id_product mod='stthemeeditor' caller='stthemeeditor'}{/if}*}
      {*{if isset($product.is_virtual) && !$product.is_virtual}{hook h="displayProductDeliveryTime" product=$product}{/if}*}
      {*{hook h="displayProductPriceBlock" product=$product type="weight"}*}
      <p v-if="item._source.description_short"
         class="product-desc {$smarty.capture.display_sd|escape:'htmlall':'UTF-8'}"
         itemprop="description"
         v-html="item._source.description_short"
      >
      </p>
      {*<div class="act_box {if $st_display_add_to_cart==1} display_when_hover {elseif $st_display_add_to_cart==2} display_normal {/if}">*}
        {*{if $st_display_add_to_cart!=3}{$smarty.capture.pro_a_cart}{/if}*}
        {*<div class="act_box_inner">*}
          {*{$smarty.capture.pro_a_compare}*}
          {*{$smarty.capture.pro_a_wishlist}*}
          {*{if trim($smarty.capture.pro_quick_view)}*}
            {*{$smarty.capture.pro_quick_view}*}
          {*{/if}*}
        {*</div>*}
      {*</div>*}
    </div>
  </div>
</div>
