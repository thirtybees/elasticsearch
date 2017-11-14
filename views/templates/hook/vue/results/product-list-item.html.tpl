<article>
  <div class="product-container">
    <div class="product-image-container">
      <a class="product_img_link"
         :href.once="item._source.link"
         :title.once="item._source.name"
      >
        <img v-if="typeof item._source !== 'undefined' && typeof item._source.image_link_large !== 'undefined'"
             class="replace-2x img-responsive center-block"
             :src.once="'//' + item._source.image_link_large.replace('search_default', 'large_default')"
                {* TODO: restore responsive images *}
                {*srcset=""*}
                {*sizes="(min-width: 1200px) 250px, (min-width: 992px) 218px, (min-width: 768px) 211px, 250px"*}
             :alt.once="item._source.name"
             :title.once="item._source.name"
        >
      </a>

      {if isset($quick_view) && $quick_view}
        <a class="quick-view show-if-product-item-hover" :href="item.link"
           title="{l s='Open quick view window' mod='elasticsearch'}" :rel="item._source.link">
          <i class="icon icon-eye-open"></i>
        </a>
      {/if}


        {* TODO: add show_price and available_for_order properties to indexed product and add this constraint *}
        {* Original smarty logic: {if (!$PS_CATALOG_MODE && ((isset($product.show_price) && $product.show_price && !isset($restricted_country_mode)) || (isset($product.available_for_order) && $product.available_for_order)))} *}
        <div v-if="{if !$PS_CATALOG_MODE}true{else}false{/if}" class="content_price show-if-product-grid-hover">
          <span class="price product-price">
            {* TODO: find a way to restore dynamic hooks *}
            {*{hook h="displayProductPriceBlock" product=$product type="before_price"}*}
            %% formatCurrency(priceTaxIncl) %%
          </span>
          {* TODO: find a way to handle discounts *}
          {*{if $product.price_without_reduction > 0 && isset($product.specific_prices) && $product.specific_prices && isset($product.specific_prices.reduction) && $product.specific_prices.reduction > 0}*}
            {*{hook h="displayProductPriceBlock" product=$product type="old_price"}*}
            {*<span class="old-price product-price">%% item._source.price_tax_incl %%*}
            {*{displayWtPrice p=$product.price_without_reduction}*}
            {*</span>*}
            {*{if $product.specific_prices.reduction_type == 'percentage'}*}
              {*<span class="price-percent-reduction">-{$product.specific_prices.reduction * 100}*}
                {*%</span>*}
            {*{/if}*}
          {*{/if}*}
          {* TODO: restore available_for_order property *}
          {* Original Smarty logic: {if $PS_STOCK_MANAGEMENT && isset($product.available_for_order) && $product.available_for_order && !isset($restricted_country_mode)} *}
          {*<span v-if="{if $PS_STOCK_MANAGEMENT}true{else}false{/if} " class="unvisible">*}
          {*{if ($product.allow_oosp || $product.quantity > 0)}*}
              {*{if $product.quantity <= 0}{if $product.allow_oosp}{if isset($product.available_later) && $product.available_later}{$product.available_later}{else}{l s='In Stock'}{/if}{/if}{else}{if isset($product.available_now) && $product.available_now}{$product.available_now}{else}{l s='In Stock'}{/if}{/if}*}
          {* TODO: check if product combinations functionality should be removed *}
          {*{elseif (isset($product.quantity_all_versions) && $product.quantity_all_versions > 0)}*}
              {*{l s='Product available with different options'}*}
          {*{else}*}
            {*{l s='Out of stock'}*}
          {*{/if}*}
          {*</span>*}
          {* TODO: find a way to restore dynamic hooks *}
          {*{hook h="displayProductPriceBlock" product=$product type="price"}*}
          {*{hook h="displayProductPriceBlock" product=$product type="unit_price"}*}
          {*{hook h="displayProductPriceBlock" product=$product type='after_price'}*}
        </div>

      {* TODO: add these properties to indexed products *}
      {*<div class="product-label-container">*}
        {*{if (!$PS_CATALOG_MODE AND ((isset($product.show_price) && $product.show_price) || (isset($product.available_for_order) && $product.available_for_order)))}*}
        {*{if isset($product.online_only) && $product.online_only}*}
        {*<span class="product-label product-label-online">{l s='Online only'}</span>*}
        {*{/if}*}
        {*{/if}*}
        {*{if isset($product.new) && $product.new == 1}*}
          {*<span class="product-label product-label-new">{l s='New'}</span>*}
        {*{/if}*}
        {*{if isset($product.on_sale) && $product.on_sale && isset($product.show_price) && $product.show_price && !$PS_CATALOG_MODE}*}
          {*<span class="product-label product-label-sale">{l s='Sale!'}</span>*}
        {*{elseif isset($product.reduction) && $product.reduction && isset($product.show_price) && $product.show_price && !$PS_CATALOG_MODE}*}
          {*<span class="product-label product-label-discount">{l s='Reduced price!'}</span>*}
        {*{/if}*}
      {*</div>*}

    </div>

    <div class="product-description-container">
      <h3 class="h4 product-name">
        {*{if isset($product.pack_quantity) && $product.pack_quantity}{$product.pack_quantity|intval|cat:' x '}{/if}*}
        <a class="product-name"
           :href="item._source.link"
           :title="item._source.name">
          %% item._source.name %%
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

      <p class="product-desc hide-if-product-grid" v-html="item._source.description_short"></p>
    </div>

    <div class="product-actions-container">
      <div class="product-price-button-wrapper">
        {*{if (!$PS_CATALOG_MODE AND ((isset($product.show_price) && $product.show_price) || (isset($product.available_for_order) && $product.available_for_order)))}*}
          <div class="content_price">
            {*{if isset($product.show_price) && $product.show_price && !isset($restricted_country_mode)}*}
              {* TODO: find a way to restore dynamic hooks *}
              {*{hook h="displayProductPriceBlock" product=$product type='before_price'}*}
              <span class="price product-price">%% formatCurrency(priceTaxIncl) %%</span>
              {*{if $product.price_without_reduction > 0 && isset($product.specific_prices) && $product.specific_prices && isset($product.specific_prices.reduction) && $product.specific_prices.reduction > 0}*}
                {* TODO: find a way to restore dynamic hooks *}
                {*{hook h="displayProductPriceBlock" product=$product type="old_price"}*}
                {*<span class="old-price product-price">*}
                {*{displayWtPrice p=$product.price_without_reduction}*}
              {*</span>*}
                {* TODO: find a way to restore dynamic hooks *}
                {*{hook h="displayProductPriceBlock" id_product=$product.id_product type="old_price"}*}
                {*{if $product.specific_prices.reduction_type == 'percentage'}*}
                  {*<span class="price-percent-reduction">-{$product.specific_prices.reduction * 100}*}
                    {*%</span>*}
                {*{/if}*}
              {*{/if}*}
              {* TODO: find a way to restore dynamic hooks *}
              {*{hook h="displayProductPriceBlock" product=$product type="price"}*}
              {*{hook h="displayProductPriceBlock" product=$product type="unit_price"}*}
              {*{hook h="displayProductPriceBlock" product=$product type='after_price'}*}
            {*{/if}*}
          {*</div>*}
        {*{/if}*}
        </div>

        <div class="button-container">
          {*{if ($product.id_product_attribute == 0 || (isset($add_prod_display) && ($add_prod_display == 1))) && $product.available_for_order && !isset($restricted_country_mode) && $product.customizable != 2 && !$PS_CATALOG_MODE}*}
          {*{if (!isset($product.customization_required) || !$product.customization_required) && ($product.allow_oosp || $product.quantity > 0)}*}
          {*{capture}add=1&amp;id_product={$product.id_product|intval}{if isset($product.id_product_attribute) && $product.id_product_attribute}&amp;ipa={$product.id_product_attribute|intval}{/if}{if isset($static_token)}&amp;token={$static_token}{/if}{/capture}*}
          <a class="ajax_add_to_cart_button btn btn-primary"
                  {*href="{$link->getPageLink('cart', true, NULL, $smarty.capture.default, false)|escape:'html':'UTF-8'}"*}
             href="#"
             rel="nofollow" title="{l s='Add to cart' mod='elasticsearch'}"
                  {*data-id-product-attribute="{$product.id_product_attribute|intval}"*}
             :data-id-product="item['_id']"
                  {*data-minimal_quantity="{if isset($product.product_attribute_minimal_quantity) && $product.product_attribute_minimal_quantity >= 1}{$product.product_attribute_minimal_quantity|intval}{else}{$product.minimal_quantity|intval}{/if}"*}
          >
            <span>{l s='Add to cart' mod='elasticsearch'}</span>
          </a>
          {*{else}*}
          {*<span class="ajax_add_to_cart_button btn btn-primary disabled">*}
          {*<span>{l s='Add to cart' mod='elasticsearch'}</span>*}
          {*</span>*}
          {*{/if}*}
          {*{/if}*}
          <a class="btn btn-default" :href="item._source.link" title="{l s='View' mod='elasticsearch'}">
            {* TODO: handle customizations *}
            <span>
              {*{if (isset($product.customization_required) && $product.customization_required)}*}
              {*{l s='Customize' mod='elasticsearch'}*}
              {*{else}*}
              {l s='More' mod='elasticsearch'}
              {*{/if}*}
            </span>
          </a>
        </div>
      </div>

      {* TODO: handle color lists *}
      {*{if isset($product.color_list)}*}
        {*<div class="color-list-container">{$product.color_list}</div>*}
      {*{/if}*}
      {*{if (!$PS_CATALOG_MODE && $PS_STOCK_MANAGEMENT && ((isset($product.show_price) && $product.show_price) || (isset($product.available_for_order) && $product.available_for_order)))}*}
        {*{if isset($product.available_for_order) && $product.available_for_order && !isset($restricted_country_mode)}*}
          <div class="availability">
            {*{if ($product.allow_oosp || $product.quantity > 0)}*}
              {*<span class="label {if $product.quantity <= 0 && isset($product.allow_oosp) && !$product.allow_oosp} label-danger{elseif $product.quantity <= 0} label-warning{else} label-success{/if}">*}

              <span v-if="item._source.quantity <= 0 && item._source.available_later" class="label label-danger">%% item._source.available_later</span>
              <span v-else-if="item._source.quantity <= 0" class="label label-danger">{l s='Out of stock' mod='elasticsearch'}</span>
              <span v-else class="label label-success">{l s='In stock' mod='elasticsearch'}</span>

              {* TODO: handle backorders *}
              {*{if $product.quantity <= 0}*}
               {*{if $product.allow_oosp}*}
                {*{if isset($product.available_later) && $product.available_later}*}
                  {*{$product.available_later}*}
                {*{else}*}
                  {*{l s='In Stock'}*}
                {*{/if}*}
              {*{else}*}
                {*{l s='Out of stock' mod='elasticsearch'}*}
              {*{/if}*}
              {*{else}*}
                {*{if isset($product.available_now) && $product.available_now}*}
                  {*{$product.available_now}*}
                {*{else}*}
                  {*{l s='In Stock' mod='elasticsearch'}*}
                {*{/if}*}
              {*{/if}*}
              {* TODO: check if product combinations functionality should be removed *}
              {*{elseif (isset($product.quantity_all_versions) && $product.quantity_all_versions > 0)}*}
              {*<span class="label label-warning">{l s='Product available with different options'}</span>*}
              {*{else}*}
              {*<span class="label label-danger">{l s='Out of stock' mod='elasticsearch'}</span>*}
            {*{/if}*}
          </div>
        {*{/if}*}
      {*{/if}*}
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
