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
<main v-if="_.indexOf(['list', 'grid'], layoutType) > -1" id="elasticsearch-results" :class="classList">
  <section id="category-info">
    <h1 class="page-heading product-listing">
      <span v-if="!query && fixedFilter && _.indexOf(['{Elasticsearch::getAlias('manufacturer')|escape:'javascript':'UTF-8'}', '{Elasticsearch::getAlias('supplier')|escape:'javascript':'UTF-8'}'], fixedFilter.aggregationCode) > -1" class="cat-name">
        %% fixedFilter.filterName %%
      </span>
      <span v-else-if="!query">
        {l s='Search' mod='elasticsearch'}
      </span>
      <span v-else class="cat-name">
        {l s='Search:' mod='elasticsearch'} <strong>%% query %%</strong>
      </span>
    </h1>
  </section>

  <product-section></product-section>
</main>
