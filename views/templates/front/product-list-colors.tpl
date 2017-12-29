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
{if isset($colors_list)}
  <ul class="color_to_pick_list clearfix">
    {foreach from=$colors_list item='color'}
      {if isset($col_img_dir)}
        {assign var='img_color_exists' value=file_exists($col_img_dir|cat:$color.id_attribute|cat:'.jpg')}
        <li>
          <a href="{$link->getProductLink($color.id_product, null, null, null, $id_lang, null, $color.id_product_attribute, Configuration::get('PS_REWRITING_SETTINGS'), false, true)|escape:'html':'UTF-8'}"
             id="color_{$color.id_product_attribute|intval}"
             class="color_pick"{if !$img_color_exists && isset($color.color) && $color.color}
              style="background:{$color.color};"{/if}
             title="{$color.name|escape:'html':'UTF-8'}"
             aria-label="{$color.name|escape:'html':'UTF-8'}"
          >
            {if $img_color_exists}
              <img src="{$img_col_dir}{$color.id_attribute|intval}.jpg" alt="{$color.name|escape:'html':'UTF-8'}" title="{$color.name|escape:'html':'UTF-8'}" width="20" height="20" />
            {/if}
          </a>
        </li>
      {/if}
    {/foreach}
  </ul>
{/if}
