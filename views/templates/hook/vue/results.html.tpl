<main v-if="_.indexOf(['list', 'grid'], layoutType) > -1" id="elasticsearch-results" :class="classList">
  <section id="category-info">
    <h1 class="page-heading product-listing">
      <span v-if="!query && fixedFilter && _.indexOf(['manufacturer', 'supplier'], fixedFilter.aggregationCode) > -1" class="cat-name">
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
