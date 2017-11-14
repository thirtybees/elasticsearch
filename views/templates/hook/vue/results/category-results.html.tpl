<main v-if="!query && fixedFilter && fixedFilter.aggregationCode === 'category' && _.indexOf(['list', 'grid'], layoutType) > -1" id="es-category-results" :class="classList">
  <product-section></product-section>
</main>
