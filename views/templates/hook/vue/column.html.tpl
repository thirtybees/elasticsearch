<section>
  <nav>
    <div id="layered_block_left" class="block">
      <h2 class="title_block section-title-column">{l s='Catalog' mod='elasticsearch'}</h2>
      <div class="block_content">
        <div id="enabled_filters" v-if="selectedFilters.length">
        <span class="layered_subtitle" style="float: none;">
        {l s='Enabled filters:' mod='elasticsearch'}
        </span>
          <ul>
            <li v-for="(filterValues, filterName) in selectedFilters">
              <a href="#"
                 title="{l s='Clear' mod='elasticsearch'}">
                <i class="icon icon-remove"></i> %% filterName %%: %%filter%%
              </a>
            </li>

          </ul>
        </div>

        <div v-for="aggregation in aggregations" v-if="aggregation.buckets.length" class="layered_filter" :key="aggregation.meta.code">
          <div class="layered_subtitle_heading">
            <span class="layered_subtitle">%% aggregation.meta.name %%</span>
          </div>
          <ul v-if="aggregation.meta.display_type == 0" class="layered_filter_ul">
            <li v-for="(bucket, index) in aggregation.buckets" class="nomargin hiddable" :key="index">
              <div class="checkbox">
                <label>
                  <input type="checkbox" :checked="isFilterChecked(bucket)" @click="toggleFilter(bucket)">
                  <a class="pointer"
                     data-rel="nofollow"
                  >
                    %% findName(bucket) %%<span> (%% bucket.doc_count %%)</span>
                  </a>
                </label>
              </div>
            </li>
          </ul>
          <ul v-if="aggregation.meta.display_type == 5" class="layered_filter_ul color-group">
            <li v-for="(bucket, index) in aggregation.buckets" class="nomargin hiddable pointer" :key="index" @click="toggleFilter(bucket)">
              <input :class="'color-option' + (isFilterChecked(bucket) ? ' on' : '')"
                     type="button"
                     :aria-label.once="findName(bucket)"
                     :style.once="'background: ' + findColorCode(bucket)"
              >
              <label class="layered_color"
                     :aria-label="findName(bucket)"
                     style="cursor: pointer"
              >
                <a data-rel="nofollow" style="cursor: pointer">
                  %% findName(bucket) %% <span style="cursor: pointer"> (%% bucket.doc_count %%)</span>
                </a>
              </label>
            </li>
          </ul>
        </div>
      </div>
    </div>
  </nav>
</section>
