<main v-if="_.indexOf(['list', 'grid'], layoutType) > -1" id="es-results" :class="classList">
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

  <section id="category-products"
           v-if="query && total || fixedFilter && _.indexOf(['manufacturer', 'supplier'], fixedFilter.aggregationCode) > -1"
  >
    <h2 class="page-heading">
      <span v-if="query || !fixedFilter">{l s='Products' mod='elasticsearch'}</span>
      <span v-else-if="fixedFilter.aggregationCode === 'manufacturer'">{l s='List of products by manufacturer' mod='elasticsearch'} <strong>%% fixedFilter.filterName %%</strong></span>
      <span v-else-if="fixedFilter.aggregationCode === 'supplier'">{l s='List of products by supplie:' mod='elasticsearch'} <strong>%% fixedFilter.filterName %%</strong></span>
      <span class="pull-right">
        <span v-if="parseInt(total, 10) === 1" class="heading-counter badge">{l s='There is' mod='elasticsearch'} %% total %% {l s='product.' mod='elasticsearch'}</span>
        <span v-else class="heading-counter badge">{l s='There are' mod='elasticsearch'} %% total %% {l s='products.' mod='elasticsearch'}</span>
      </span>
    </h2>
    <div class="content_sortPagiBar clearfix">
      <div class="form-inline sortPagiBar clearfix">
        <div id="product-list-switcher" class="form-group display">
          <label class="visible-xs">{l s='Display product list as:' mod='elasticsearch'}</label>
          <div class="btn-group" role="group" aria-label="Product list display type">
            <a id="es-grid"
               :class="'btn btn-default' + (layoutType === 'grid' ? ' selected active' : '')"
               rel="nofollow"
               @click="setLayoutType('grid')"
               title="{l s='Grid' mod='elasticsearch'}"
               style="cursor: pointer"
            >
              <i class="icon icon-fw icon-th"></i>
              <span class="visible-xs">{l s='Grid' mod='elasticsearch'}</span>
            </a>
            <a id="es-list"
               :class="'btn btn-default'  + (layoutType === 'list' ? ' selected active' : '')"
               rel="nofollow"
               @click="setLayoutType('list')"
               title="{l s='List' mod='elasticsearch'}"
               style="cursor: pointer"
            >
              <i class="icon icon-fw icon-bars"></i>
              <span class="visible-xs">{l s='List' mod='elasticsearch'}</span>
            </a>
          </div>
        </div>

        {* TODO: implement sort by *}
        {*<div id="productsSortForm" class="form-group productsSortForm">*}
          {*<label for="selectProductSort">Sort by</label>*}
          {*<select id="selectProductSort" class="selectProductSort form-control">*}
            {*<option value="date_add:asc" selected="selected">--</option>*}
            {*<option value="price:asc">Price: Lowest first</option>*}
            {*<option value="price:desc">Price: Highest first</option>*}
            {*<option value="name:asc">Product Name: A to Z</option>*}
            {*<option value="name:desc">Product Name: Z to A</option>*}
            {*<option value="quantity:desc">In stock</option>*}
            {*<option value="reference:asc">Reference: Lowest first</option>*}
            {*<option value="reference:desc">Reference: Highest first</option>*}
          {*</select>*}
        {*</div>*}

        <div class="js-per-page form-group" v-if="!infiniteScroll">
          <label for="nb_item">{l s='Items per page:' mod='elasticsearch'}</label>
          <select @input="itemsPerPageHandler" class="form-control">
            <option v-for="itemsPerPage in itemsPerPageOptions"
                    :value.once="itemsPerPage"
                    :selected="itemsPerPage === limit"
                    :key="itemsPerPage"
            >%% itemsPerPage %%</option>
          </select>
        </div>
      </div>

      <div class="top-pagination-content form-inline clearfix" v-if="!infiniteScroll">
        <pagination :limit="limit" :offset="offset" :total="total"></pagination>

        <show-all></show-all>

        <product-count :limit="limit" :offset="offset" :total="total"></product-count>
      </div>
      {* TODO: restore product comparison functionality *}
      {*<div class="form-group compare-form">*}
        {*<form method="post" action="https://thirtybees.example.com/products-comparison">*}
          {*<button type="submit" class="btn btn-success bt_compare bt_compare" disabled="disabled">*}
            {*<span>Compare (<strong class="total-compare-val">0</strong>) »</span>*}
          {*</button>*}
          {*<input type="hidden" name="compare_product_count" class="compare_product_count" value="0">*}
          {*<input type="hidden" name="compare_product_list" class="compare_product_list" value="">*}
        {*</form>*}
      {*</div>*}
    </div>

    <ul :class="'product_list list-grid row ' + layoutType">
      <li v-for="result in results" class="ajax_block_product col-xs-12 col-sm-6 col-md-4" :key="result['_id']">
        <product-list-item :item="result"></product-list-item>
      </li>
    </ul>

    <div class="content_sortPagiBar" v-if="!infiniteScroll">
      <div class="bottom-pagination-content form-inline clearfix">
        <pagination :limit="limit" :offset="offset" :total="total"></pagination>
        <show-all></show-all>
        <product-count :limit="limit" :offset="offset" :total="total"></product-count>
      </div>
      {* TODO: restore compare functionality *}
      {*<div class="form-group compare-form">*}
        {*<form method="post" action="https://thirtybees.example.com/products-comparison">*}
          {*<button type="submit" class="btn btn-success bt_compare bt_compare" disabled="disabled">*}
            {*<span>Compare (<strong class="total-compare-val">0</strong>) »</span>*}
          {*</button>*}
          {*<input type="hidden" name="compare_product_count" class="compare_product_count" value="0">*}
          {*<input type="hidden" name="compare_product_list" class="compare_product_list" value="">*}
        {*</form>*}
      {*</div>*}
    </div>
    <infinite-loading @infinite="loadMoreProducts" v-if="infiniteScroll">
      <span slot="no-more">
        {l s='You\'ve reached the end of the list' mod='elasticsearch'}
      </span>
    </infinite-loading>
  </section>
  <section id="category-products" v-else-if="!query">
    <div class="alert alert-warning">
      {l s='Please enter a search keyword' mod='elasticsearch'}
    </div>
  </section>
  <section id="category-products" v-else>
    <div class="alert alert-warning">
      {l s='No results found' mod='elasticsearch'}
    </div>
  </section>
</main>
