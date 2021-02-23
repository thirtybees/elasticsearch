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
	  
	  <div class="brandname">
	    %% item._source['{Elasticsearch::getAlias('manufacturer')|escape:'javascript':'UTF-8'}'] %%
	  </div>

    </div>
	
	<div class="availability" v-if="item._source['{Elasticsearch::getAlias('show_price')|escape:'javascript':'UTF-8'}'] && item._source['{Elasticsearch::getAlias('available_for_order')|escape:'javascript':'UTF-8'}'] && {if !isset($restricted_country_mode)}true{else}false{/if}">	
		<template v-if="item._source['{Elasticsearch::getAlias('stock_qty')|escape:'javascript':'UTF-8'}'] <= 0">
			<span v-if="item._source['{Elasticsearch::getAlias('allow_oosp')|escape:'javascript':'UTF-8'}'] || item._source['{Elasticsearch::getAlias('available_later')|escape:'javascript':'UTF-8'}']" class="label label-warning"> Pré-commande </span>
			<span v-else class="label label-danger"> Hors stock </span>
		</template>
		<template v-else>
			<span class="label label-success"> En stock </span>
		</template>	
	</div>
	
	<div class="product-reference-container">
		<p id="product_reference">
			<a class="product-name" 
				:href.once="item._source['{Elasticsearch::getAlias('link')|escape:'javascript':'UTF-8'}']" 
				:title.once="item._source['{Elasticsearch::getAlias('name')|escape:'javascript':'UTF-8'}']" itemprop="url">
				<span class="editable" itemprop="sku" 
				:content.once="item._source['{Elasticsearch::getAlias('reference')|escape:'javascript':'UTF-8'}']">%% item._source['{Elasticsearch::getAlias('reference')|escape:'javascript':'UTF-8'}'] %%</span>
			</a>
		</p>
		<div class="prixderef">
			<p class="price_reference" v-if="item._source ['{Elasticsearch::getAlias('price_reference')|escape:'javascript':'UTF-8'}'] !== '0,00'">
				<span class="smaller">Prix public ttc:</span>%% item._source['{Elasticsearch::getAlias('price_reference')|escape:'javascript':'UTF-8'}'] %% €
			</p>
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
      <p class="product-desc hide-if-product-grid" v-html="item._source['{Elasticsearch::getAlias('description_short')|escape:'javascript':'UTF-8'}']"></p>
    </div>

    <div v-if="idGroup != 1" class="product-actions-container">
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

        <div class="button-container" v-if="!item._source['{Elasticsearch::getAlias('color_list')|escape:'javascript':'UTF-8'}']">
          <a v-if="item._source['{Elasticsearch::getAlias('available_for_order')|escape:'javascript':'UTF-8'}'] && !item._source['{Elasticsearch::getAlias('customization_required')|escape:'javascript':'UTF-8'}'] && (item._source['{Elasticsearch::getAlias('allow_oosp')|escape:'javascript':'UTF-8'}'] || item._source['{Elasticsearch::getAlias('in_stock')|escape:'htmlall':'UTF-8'}']) && {if !isset($restricted_country_mode)}true{else}false{/if} && {if !$PS_CATALOG_MODE}true{else}false{/if}"
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
        </div>
      
		<div class="button-container" v-else>
		  <a class="btn btn-primary" 
			:href.once="item._source['{Elasticsearch::getAlias('link')|escape:'javascript':'UTF-8'}']"
			:title.once="item._source['{Elasticsearch::getAlias('name')|escape:'javascript':'UTF-8'}']">
			<span>Voir le produit</span>
		  </a>
        </div>	
	  
	  </div>
	 
      <div v-html="item._source['{Elasticsearch::getAlias('color_list')|escape:'javascript':'UTF-8'}']" class="color-list-container"></div>
    </div>
  </div>
</article>
