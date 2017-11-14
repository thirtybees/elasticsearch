<section id="es-category-results" v-if="!query && fixedFilter && fixedFilter.aggregationCode === 'category' && _.indexOf(['list', 'grid'], layoutType) > -1" :class="classList">
  <product-section></product-section>
</section>
