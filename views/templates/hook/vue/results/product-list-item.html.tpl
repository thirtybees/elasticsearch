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
<article>
  <div class="product-container">
    <div class="product-image-container">
      <a class="product_img_link"
         :href.once="item._source['{Elasticsearch::getAlias('link')|escape:'javascript':'UTF-8'}']"
         :title.once="item._source['{Elasticsearch::getAlias('name')|escape:'javascript':'UTF-8'}']"
      >
        <img v-if="typeof item._source !== 'undefined' && typeof item._source['{Elasticsearch::getAlias('image_link_large')|escape:'javascript':'UTF-8'}'] !== 'undefined'"
             class="replace-2x img-responsive center-block"
             :src.once="'//' + item._source['{Elasticsearch::getAlias('image_link_large')|escape:'javascript':'UTF-8'}'].replace('search_default', 'large_default')"
                {* TODO: restore responsive images *}
                {*srcset=""*}
                {*sizes="(min-width: 1200px) 250px, (min-width: 992px) 218px, (min-width: 768px) 211px, 250px"*}
             :alt.once="item._source['{Elasticsearch::getAlias('name')|escape:'javascript':'UTF-8'}']"
             :title.once="item._source['{Elasticsearch::getAlias('name')|escape:'javascript':'UTF-8'}']"
        >
      </a>

      {if isset($quick_view) && $quick_view}
        <a class="quick-view show-if-product-item-hover" :href="item._source['{Elasticsearch::getAlias('link')|escape:'javascript':'UTF-8'}']"
           title="{l s='Open quick view window' mod='elasticsearch'}" :rel="item._source['{Elasticsearch::getAlias('link')|escape:'javascript':'UTF-8'}']">
          <i class="icon icon-eye-open"></i>
        </a>
      {/if}

      {* TODO: add show_price and available_for_order properties to indexed product and add this constraint *}
      <div v-if="{if !$PS_CATALOG_MODE && !isset($restricted_country_mode)}true{else}false{/if} && item._source['{Elasticsearch::getAlias('show_price')|escape:'javascript':'UTF-8'}'] || item._source['{Elasticsearch::getAlias('available_for_order')|escape:'javascript':'UTF-8'}']" class="content_price show-if-product-grid-hover">
        <span class="price product-price">
          {* TODO: find a way to restore dynamic hooks *}
          {*{hook h="displayProductPriceBlock" product=$product type="before_price"}*}
          %% formatCurrency(priceTaxIncl) %%
        </span>
        {* TODO: find a way to handle discounts *}
        <span v-if="basePriceTaxIncl > priceTaxIncl">
          {*{hook h="displayProductPriceBlock" product=$product type="old_price"}*}
          <span class="old-price product-price">%% formatCurrency(basePriceTaxIncl) %%</span>&nbsp;
          <span class="price-percent-reduction">-%% discountPercentage %%%</span>
        </span>
        {* TODO: find a way to restore dynamic hooks *}
        {*{hook h="displayProductPriceBlock" product=$product type="price"}*}
        {*{hook h="displayProductPriceBlock" product=$product type="unit_price"}*}
        {*{hook h="displayProductPriceBlock" product=$product type='after_price'}*}
      </div>

      <div v-if="{if !PS_CATALOG_MODE}true{else}false{/if} && item._source['{Elasticsearch::getAlias('show_price')|escape:'javascript':'UTF-8'}'] || item._source['{Elasticsearch::getAlias('available_for_order')|escape:'javascript':'UTF-8'}']" class="product-label-container">
        <span v-if="item._source['{Elasticsearch::getAlias('online_only')|escape:'javascript':'UTF-8'}']" class="product-label product-label-online">{l s='Online only' mod='elasticsearch'}</span>
        <span v-else-if="item._source['{Elasticsearch::getAlias('new')|escape:'javascript':'UTF-8'}']" class="product-label product-label-new">{l s='New' mod='elasticsearch'}</span>
        <span v-else-if="item._source['{Elasticsearch::getAlias('on_sale')|escape:'javascript':'UTF-8'}']" class="product-label product-label-sale">{l s='Sale!' mod='elasticsearch'}</span>
        <span v-else-if="basePriceTaxIncl > priceTaxIncl" class="product-label product-label-discount">{l s='Reduced price!' mod='elasticsearch'}</span>
      </div>

    </div>

    <div class="product-description-container">
      <h3 class="h4 product-name">
        <span v-if="item._source['{Elasticsearch::getAlias('pack_quantity')|escape:'javascript':'UTF-8'}']">%% item._source['{Elasticsearch::getAlias('pack_quantity')|escape:'javascript':'UTF-8'}'] %% x </span>
        <a class="product-name"
           :href="item._source['{Elasticsearch::getAlias('link')|escape:'javascript':'UTF-8'}']"
           :title="item._source['{Elasticsearch::getAlias('name')|escape:'javascript':'UTF-8'}']">
          %% item._source['{Elasticsearch::getAlias('name')|escape:'javascript':'UTF-8'}'] %%
        </a>
      </h3>

      {* TODO: handle reviews *}
      {*{capture name='displayProductListReviews'}{hook h='displayProductListReviews' product=$product}{/capture}*}
      {*{if $smarty.capture.displayProductListReviews}*}
        {*<div class="hook-reviews">*}
          {*{hook h='displayProductListReviews' product=$product}*}
        {*</div>*}
      {*{/if}*}

      {* TODO: handle dynamic hooks *}
      {*{if isset($product.is_virtual) && !$product.is_virtual}{hook h="displayProductDeliveryTime" product=$product}{/if}*}
      {*{hook h="displayProductPriceBlock" product=$product type="weight"}*}

      <p class="product-desc hide-if-product-grid" v-html="item._source['{Elasticsearch::getAlias('description_short')|escape:'javascript':'UTF-8'}']"></p>
    </div>

    <div class="product-actions-container">
      <div class="product-price-button-wrapper">
          <div v-if="{if !$PS_CATALOG_MODE}true{else}false{/if} && item._source['{Elasticsearch::getAlias('show_price')|escape:'javascript':'UTF-8'}'] || item._source['{Elasticsearch::getAlias('available_for_order')|escape:'javascript':'UTF-8'}']" class="content_price">
            {* TODO: find a way to restore dynamic hooks *}
            {*{hook h="displayProductPriceBlock" product=$product type='before_price'}*}
            <span v-if="item._source['{Elasticsearch::getAlias('show_price')|escape:'javascript':'UTF-8'}'] && {if !isset($restricted_country_mode)}true{else}false{/if}"
                  class="price product-price">
              %% formatCurrency(priceTaxIncl) %%
            </span>
            <span v-if="item._source['{Elasticsearch::getAlias('show_price')|escape:'javascript':'UTF-8'}'] && {if !isset($restricted_country_mode)}true{else}false{/if} && basePriceTaxIncl > priceTaxIncl">
              {* TODO: find a way to restore dynamic hooks *}
              {*{hook h="displayProductPriceBlock" product=$product type="old_price"}*}
              <span class="old-price product-price">%% formatCurrency(basePriceTaxIncl) %%</span>
              {* TODO: find a way to restore dynamic hooks *}
              {*{hook h="displayProductPriceBlock" id_product=$product.id_product type="old_price"}*}
              <span class="price-percent-reduction">-%% discountPercentage %%%</span>
            </span>
            {* TODO: find a way to restore dynamic hooks *}
            {*{hook h="displayProductPriceBlock" product=$product type="price"}*}
            {*{hook h="displayProductPriceBlock" product=$product type="unit_price"}*}
            {*{hook h="displayProductPriceBlock" product=$product type='after_price'}*}
        </div>

        <div class="button-container">
          <a v-if="item._source['{Elasticsearch::getAlias('in_stock')|escape:'javascript':'UTF-8'}'] && item._source['{Elasticsearch::getAlias('available_for_order')|escape:'javascript':'UTF-8'}'] && !item._source['{Elasticsearch::getAlias('customization_required')|escape:'javascript':'UTF-8'}'] && (item._source['{Elasticsearch::getAlias('allow_oosp')|escape:'javascript':'UTF-8'}'] || item._source.in_stock) && {if !isset($restricted_country_mode)}true{else}false{/if} && {if !$PS_CATALOG_MODE}true{else}false{/if}"
             class="ajax_add_to_cart_button btn btn-primary"
             style="cursor: pointer"
             rel="nofollow" title="{l s='Add to cart' mod='elasticsearch'}"
             :data-id-product.once="item._id"
             :data-minimal_quantity="item._source['{Elasticsearch::getAlias('minimal_quantity')|escape:'javascript':'UTF-8'}'] ? item._source['{Elasticsearch::getAlias('minimal_quantity')|escape:'javascript':'UTF-8'}'] : 1"
          >
            <span>{l s='Add to cart' mod='elasticsearch'}</span>
          </a>

          <span v-else class="ajax_add_to_cart_button btn btn-primary disabled">
            <span>{l s='Add to cart' mod='elasticsearch'}</span>
          </span>
          <a class="btn btn-default" :href="item._source['{Elasticsearch::getAlias('link')|escape:'javascript':'UTF-8'}']" title="{l s='View' mod='elasticsearch'}">
            <span v-if="item._source['{Elasticsearch::getAlias('customization_required')|escape:'javascript':'UTF-8'}']">
             {l s='Customize' mod='elasticsearch'}
            </span>
            <span v-else>
              {l s='More' mod='elasticsearch'}
            </span>
          </a>
        </div>
      </div>

      <div v-if="item._source['{Elasticsearch::getAlias('color_list')|escape:'javascript':'UTF-8'}']" v-html="item._source['{Elasticsearch::getAlias('color_list')|escape:'javascript':'UTF-8'}']" class="color-list-container"></div>
          <stock-badge :item.once="item"></stock-badge>
      {* TODO: restore show_functional_buttons variable *}
      {*{if $show_functional_buttons}*}
        {*<div class="functional-buttons clearfix show-if-product-grid-hover">*}
          {* TODO: find a way to restore dynamic hooks *}
          {*{hook h='displayProductListFunctionalButtons' product=$product}*}

          {* TODO: find a way to restore product comparison *}
          {*{if isset($comparator_max_item) && $comparator_max_item}*}
            {*<div class="compare">*}
              {*<a class="add_to_compare"*}
                 {*:href="item._source.link"*}
                 {*:data-id-product="item['_id']">*}
                {*<i class="icon icon-plus"></i> {l s='Add to Compare' mod='elasticsearch'}*}
              {*</a>*}
            {*</div>*}
          {*{/if}*}
        {*</div>*}
      {*{/if}*}
    </div>

  </div>
</article>
