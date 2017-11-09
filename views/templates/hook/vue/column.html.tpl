<section>
  <nav>
    <div id="layered_block_left" class="block">
      <h2 class="title_block section-title-column">{l s='Catalog' mod='elasticsearch'}</h2>
      <div class="block_content">
        <div id="enabled_filters" v-if="_.values(selectedFilters).length">
        <span class="layered_subtitle" style="float: none;">
        {l s='Enabled filters:' mod='elasticsearch'}
        </span>
          <ul v-for="(filter, filterName) in selectedFilters">
            <li v-if="filter.display_type == 4"
                style="cursor: pointer"
                @click="removeRangeFilter(filter.code)"
            >
              <a title="{l s='Cancel' mod='elasticsearch'}">
                <i class="icon icon-remove"></i>
              </a>
              %% filter.name %%: %% formatCurrency(filter.values.min) %% - %% formatCurrency(filter.values.max) %%
            </li>
            <li v-if="filter.display_type != 4" v-for="value in filter.values"
                style="cursor: pointer"
                @click="removeFilter(filter.code, filter.name, value.code, value.name)"
            >
              <a title="{l s='Cancel' mod='elasticsearch'}">
                <i class="icon icon-remove"></i>
              </a>
              %% filter.name %%: %% value.name %%
            </li>
          </ul>
        </div>
        <div v-for="(aggregation, aggregationName) in aggregations" v-if="aggregation.meta.code.slice(-3) === 'min' && aggregation.value !== null || aggregation.buckets && aggregation.buckets.length" class="layered_filter" :key="aggregation.meta.code">
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
          <ul v-if="aggregation.meta.display_type == 4 && aggregation.value !== null" class="layered_filter_ul">
            <br />
            <br />
            <range-slider style="margin-left: auto; margin-right: auto"
                          width="88%"
                          :value.once="[findSelectedMin(aggregation.meta.slider_code), findSelectedMax(aggregation.meta.slider_code)]"
                          :min.once="findMin(aggregation.meta.slider_code)"
                          :max.once="findMax(aggregation.meta.slider_code)"
                          :tooltip-style.once="{ backgroundColor: '#fad629', border: '1px solid #fad629', color: '#000', fontWeight: '700'}"
                          :process-style.once=" { backgroundColor: '#fad629' }"
                          @drag-end="processRangeSlider(aggregation.meta.slider_agg_code, aggregation.meta.slider_code, $event)"
            ></range-slider>
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
