{*
* 2007-2014 PrestaShop
*
* NOTICE OF LICENSE
*
* This source file is subject to the Academic Free License (AFL 3.0)
* that is bundled with this package in the file LICENSE.txt.
* It is also available through the world-wide-web at this URL:
* http://opensource.org/licenses/afl-3.0.php
* If you did not receive a copy of the license and are unable to
* obtain it through the world-wide-web, please send an email
* to license@prestashop.com so we can send you a copy immediately.
*
* DISCLAIMER
*
* Do not edit or add to this file if you wish to upgrade PrestaShop to newer
* versions in the future. If you wish to customize PrestaShop for your
* needs please refer to http://www.prestashop.com for more information.
*
*  @author PrestaShop SA <contact@prestashop.com>
*  @copyright  2007-2014 PrestaShop SA
*  @license    http://opensource.org/licenses/afl-3.0.php  Academic Free License (AFL 3.0)
*  International Registered Trademark & Property of PrestaShop SA
*}
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


  <div class="product-container">
    <div class="left-block">
      <div class="product-image-container">
        {* TODO: find a way to restore hooks *}
        {*{if (isset($product.quantity) && $product.quantity > 0) || (isset($product.quantity_all_versions) && $product.quantity_all_versions > 0)}*}
          {*{hook h='displayProductAttributesPL' productid=$product.id_product}*}
        {*{/if}*}
        <a class="product_img_link" :href.once="item._source[{Elasticsearch::getAlias('link')|escape:'javascript':'UTF-8'}']" >
          <img class="replace-2x img-responsive img_0 lazy"
            {*{if (isset($iqit_lazy_load)  && $iqit_lazy_load) || (isset($warehouse_vars.iqit_lazy_load)  && $warehouse_vars.iqit_lazy_load == 1)}*}
              {*:data-original.once="item._source.image_link_large"*}
              {*src="{$img_dir|escape:'htmlall':'UTF-8'}blank.gif"*}
            {*{else}*}
            :src.once="'//' + item._source['{Elasticsearch::getAlias('image_link_large')|escape:'javascript':'UTF-8'}'"
            {*{/if}*}
            :alt.once="item._source['{Elasticsearch::getAlias('name')|escape:'javascript':'UTF-8'}']"
            :title.once="item._source['{Elasticsearch::getAlias('name')|escape:'javascript':'UTF-8'}']"
            {if isset($homeSize)} width="{$homeSize.width|intval}" height="{$homeSize.height|intval}"{/if}
          />
          <img class="replace-2x img-responsive img_1 lazy"
            {*{if (isset($iqit_lazy_load) && $iqit_lazy_load== 1) || (isset($warehouse_vars.iqit_lazy_load)  && $warehouse_vars.iqit_lazy_load == 1)}*}
              {*:data-original.onc="item._source.image_link_large"*}
              {*src="{$img_dir|escape:'htmlall':'UTF-8'}blank.gif"*}
            {*{else}*}
            :src.once="'//' + item._source['{Elasticsearch::getAlias('image_link_large')|escape:'javascript':'UTF-8'}']"
            {*{/if}*}
            :alt.once="item._source['{Elasticsearch::getAlias('name')|escape:'javascript':'UTF-8'}']"
            :title.once="item._source['{Elasticsearch::getAlias('name')|escape:'javascript':'UTF-8'}']"
            {if isset($homeSize)} width="{$homeSize.width|intval}" height="{$homeSize.height|intval}"{/if}
          />

          {*{hook h='displayCountDown' product=$product}*}
        </a>

        <div v-if="{if !PS_CATALOG_MODE}true{else}false{/if} && item._source['{Elasticsearch::getAlias('show_price')|escape:'javascript':'UTF-8'}'] || item._source['{Elasticsearch::getAlias('available_for_order')|escape:'javascript':'UTF-8'}']"
             class="product-flags">
          <span v-if="item._source'{Elasticsearch::getAlias('online_only')|escape:'javascript':'UTF-8'}']"
                :class.once="'online_label' + (item._source['{Elasticsearch::getAlias('new')|escape:'javascript':'UTF-8'}'] ? ' online-label2' : '')"
          >{l s='Online only' mod='elasticsearch'}
          </span>
          <span v-else-if="item._source'{Elasticsearch::getAlias('new')|escape:'javascript':'UTF-8'}']"
                class="product-label product-label-new"
          >
            {l s='New' mod='elasticsearch'}
          </span>
          <span v-else-if="item._source['{Elasticsearch::getAlias('on_sale')|escape:'javascript':'UTF-8'}'] && !(basePriceTaxIncl > priceTaxIncl)" class="sale-label">
            {l s='Sale!' mod='elasticsearch'}
          </span>
          <span v-else-if="basePriceTaxIncl > priceTaxIncl" class="sale-label">
            {l s='Reduced price!' mod='elasticsearch'}
          </span>
        </div>

        <div class="functional-buttons functional-buttons-grid clearfix">
          {if isset($quick_view) && $quick_view}
            <div class="quickview col-xs-6">
              <a class="quick-view" :href.once="item._source['{Elasticsearch::getAlias('link')|escape:'javascript':'UTF-8'}']"
                 :rel.once="item._source['{Elasticsearch::getAlias('link')|escape:'javascript':'UTF-8'}']"
                 title="{l s='Quick view' mod='elasticsearch'}"
              >
                {l s='Quick view' mod='elasticsearch'}
              </a>
            </div>
          {/if}

          {* TODO: find a way to restore hooks *}
          {*{hook h='displayProductListFunctionalButtons' product=$product}*}

          {* TODO: restore compare *}
          {*{if isset($comparator_max_item) && $comparator_max_item}*}
            {*<div class="compare col-xs-3">*}
              {*<a class="add_to_compare" href="{$product.link|escape:'html':'UTF-8'}" data-id-product="{$product.id_product}" title="{l s='Add to Compare'}">{l s='Add to Compare'}</a>*}
            {*</div>*}
          {*{/if}*}
        </div>

        {*{if (!$PS_CATALOG_MODE && $PS_STOCK_MANAGEMENT && ((isset($product.show_price) && $product.show_price) || (isset($product.available_for_order) && $product.available_for_order)))}*}
          {*{if isset($product.available_for_order) && $product.available_for_order && !isset($restricted_country_mode)}*}
            <span class="availability availability-slidein">
              <link v-if="item._source['{Elasticsearch::getAlias('allow_oosp')|escape:'javascript':'UTF-8'}'] || item._source['{Elasticsearch::getAlias('in_stock')|escape:'javascript':'UTF-8'}']"
                    href="http://schema.org/InStock"
              />
              {*<span v-else-if="item._source.in_stock" class="available-dif">*}
                {*<link href="http://schema.org/LimitedAvailability" />{l s='Product available with different options' mod='elasticserach'}*}
              {*</span>*}
              <span v-else class="out-of-stock">
                <link  href="http://schema.org/OutOfStock" />{l s='Out of stock' mod='elasticsearch'}
              </span>
            </span>
          {*{/if}*}
        {*{/if}*}

        <div v-if="item._source['{Elasticsearch::getAlias('color_list')|escape:'javascript':'UTF-8'}']"
             class="color-list-container"
             v-html="item._source['{Elasticsearch::getAlias('color_list')|escape:'javascript':'UTF-8'}']"></div>
      </div>

      {* TODO: find a way to restore hooks *}
      {*{if isset($product.is_virtual) && !$product.is_virtual}{hook h="displayProductDeliveryTime" product=$product}{/if}*}
      {*{hook h="displayProductPriceBlock" product=$product type="weight"}*}
    </div>
    <div class="right-block">
      <h5  class="product-name-container">
        {*{if isset($product.pack_quantity) && $product.pack_quantity}{$product.pack_quantity|intval|cat:' x '}{/if}*}
        <a class="product-name" :href.once="item._source['{Elasticsearch::getAlias('link')|escape:'javascript':'UTF-8'}']"
           title="item._source['{Elasticsearch::getAlias('name')|escape:'javascript':'UTF-8'}']"
        >
          %% item._source['{Elasticsearch::getAlias('name')|escape:'javascript':'UTF-8'}'] %%
        </a>
      </h5>
      <span v-if="item._source['{Elasticsearch::getAlias('reference')|escape:'javascript':'UTF-8'}']"
            class="product-reference"
      >
        %% item._source['{Elasticsearch::getAlias('reference')|escape:'javascript':'UTF-8'}'] %%
      </span>
      <span v-else="item._source['{Elasticsearch::getAlias('reference')|escape:'javascript':'UTF-8'}']"
            class="product-reference"
      >
        &nbsp;
      </span>
      <p class="product-desc" >
        %% item._source['{Elasticsearch::getAlias('description_short')|escape:'javascript':'UTF-8'}'] %%
      </p>
      <div v-if="{if !isset($restricted_country_mode)}true{else}false{/if} && item._source['{Elasticsearch::getAlias('show_price')|escape:'javascript':'UTF-8'}'] || item._source['{Elasticsearch::getAlias('available_for_order')|escape:'javascript':'UTF-8'}']" itemscope class="content_price">
        <span  class="price product-price">
          {* TODO: find a way to restore hooks *}
          {*{hook h="displayProductPriceBlock" product=$product type="before_price"}*}
          %% formatCurrency(priceTaxIncl) %%
        </span>
        {*{if isset($product.specific_prices) && $product.specific_prices && isset($product.specific_prices.reduction) && $product.specific_prices.reduction > 0}*}
          {* TODO: find a way to restore hooks *}
          {*{hook h="displayProductPriceBlock" product=$product type="old_price"}*}
        <span v-if="basePriceTaxIncl > priceTaxIncl" class="old-price product-price">
          %% formatCurrency(basePriceTaxIncl) %%
        </span>
        {*{/if}*}
        {* TODO: find a way to restore hooks *}
        {*{hook h="displayProductPriceBlock" product=$product type="price"}*}
        {*{hook h="displayProductPriceBlock" product=$product type="unit_price"}*}
      </div>
      <div v-else-if="{if !$PS_CATALOG_MODE}true{else}false{/if}" class="content_price">&nbsp;</div>
      {* TODO: find a way to restore hooks *}
      {*{hook h='displayProductListReviews' product=$product}*}
      <div class="button-container">
            <a v-if="{if isset($add_prod_display) && $add_prod_display && !isset($restricted_country_mode) && !$PS_CATALOG_MODE}true{else}false{/if} && (!item._source['{Elasticsearch::getAlias('customization_required')|escape:'javascript':'UTF-8'}'] && (item._source['{Elasticsearch::getAlias('allow_oosp')|escape:'javascript':'UTF-8'}'] || item._source['{Elasticsearch::getAlias('in_stock')|escape:'javascript':'UTF-8'}'])"
               class="button ajax_add_to_cart_button btn btn-default"
               href="{$link->getPageLink('cart', true, NULL, $smarty.capture.default, false)|escape:'html':'UTF-8'}"
               rel="nofollow"
               title="{l s='Add to cart' mod='elasticsearch'}"
               :data-id-product.once="item._id"
               :data-minimal_quantity.once="item._source['{Elasticsearch::getAlias('minimal_quantity')|escape:'javascript':'UTF-8'}'] ? item._source['{Elasticsearch::getAlias('minimal_quantity')|escape:'javascript':'UTF-8'}'] : 1">
              <span>{l s='Add to cart'}</span>
            </a>
            <div v-if="{if isset($add_prod_display) && $add_prod_display && !isset($restricted_country_mode) && !$PS_CATALOG_MODE}true{else}false{/if} && (!item._source['{Elasticsearch::getAlias('customization_required')|escape:'javascript':'UTF-8'}'] && (item._source['{Elasticsearch::getAlias('allow_oosp')|escape:'javascript':'UTF-8'}'] || item._source['{Elasticsearch::getAlias('in_stock')|escape:'javascript':'UTF-8'}'])"
                 class="pl-quantity-input-wrapper"
            >
              <input type="text"
                     name="qty"
                     :class.once="'form-control qtyfield quantity_to_cart_' + item._id"
                     :value.once="item._source['{Elasticsearch::getAlias('minimal_quantity')|escape:'javascript':'UTF-8'}']"/>
              <div class="quantity-input-b-wrapper">
                <a href="#" :data-field-qty.once="'quantity_to_cart_' + item._id" class="transition-300 pl_product_quantity_down">
                  <span><i class="icon-caret-down"></i></span>
                </a>
                <a href="#" :data-field-qty.once="'quantity_to_cart_' + item._id" class="transition-300 pl_product_quantity_up ">
                  <span><i class="icon-caret-up"></i></span>
                </a>
              </div>
            </div>
            <a v-else
               class="button lnk_view btn"
               :href.once="item._source['{Elasticsearch::getAlias('link')|escape:'javascript':'UTF-8'}']"
               title="{l s='View' mod='elasticsearch'}"
            >
              <span v-if="item._source['{Elasticsearch::getAlias('customization_required')|escape:'javascript':'UTF-8'}']">
                {l s='Customize' mod='elasticsearch'}
              </span>
              <span v-else>{l s='More' mod='elasticsearch'}</span>
            </a>
          <a v-else class="button lnk_view btn"
             :href.once="item._source['{Elasticsearch::getAlias('link')|escape:'javascript':'UTF-8'}']"
             title="{l s='View'}"
          >
            <span v-if="item._source['{Elasticsearch::getAlias('customization_required')|escape:'javascript':'UTF-8'}']">
              {l s='Customize' mod='elasticsearch'}
            </span>
            <span v-else>{l s='More' mod='elasticsearch'}</span>
          </a>

        {* TODO: Find a way to restore hooks *}
        {*{hook h="displayProductPriceBlock" product=$product type='after_price'}*}
      </div>
    </div>
  </div>

