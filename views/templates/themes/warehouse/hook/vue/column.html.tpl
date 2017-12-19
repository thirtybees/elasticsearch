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
<section v-if="!_.isEmpty(selectedFilters) || query">
  <nav>
    <div id="layered_form" class="block">
      <h2 class="title_block section-title-column">{l s='Catalog' mod='elasticsearch'}</h2>
      <div class="block_content">
        <div id="enabled_filters" v-if="!_.isEmpty(selectedFilters)">
        <span class="layered_subtitle" style="float: none;">
          {l s='Enabled filters:' mod='elasticsearch'}
        </span>
          <ul v-for="filter in selectedFilters">
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
                :style.once="!value.fixed ? 'cursor: pointer' : ''"
                @click="removeFilter(filter.code, filter.name, value.code, value.name)"
            >
              <a title="{l s='Cancel' mod='elasticsearch'}" v-if="!value.fixed">
                <i class="icon icon-remove"></i>
              </a>
              %% filter.name %%: %% value.name %%
            </li>
          </ul>
        </div>
        <div v-for="(aggregation, aggregationCode) in aggregations" v-if="total && !hasFixedFilter(aggregation.code)" class="layered_filter" :key="aggregation.code">
          <div class="layered_subtitle_heading">
            <span class="layered_subtitle">%% aggregation.name %%</span>
          </div>
          <ul v-if="aggregation.display_type == 4" class="layered_filter_ul">
            <br />
            <br />
            <range-slider style="margin-left: auto; margin-right: auto"
                          width="88%"
                          :value.once="[findSelectedMin(aggregation.code), findSelectedMax(aggregation.code)]"
                          :min.once="findMin(aggregation.code)"
                          :max.once="findMax(aggregation.code)"
                          :tooltip-style.once="{ backgroundColor: '#fad629', border: '1px solid #fad629', color: '#000', fontWeight: '700'}"
                          :process-style.once=" { backgroundColor: '#fad629' }"
                          @drag-end="processRangeSlider(aggregation.code, aggregation.name, $event)"
            ></range-slider>
          </ul>
          <ul v-else-if="aggregation.display_type == 5" class="layered_filter_ul color-group">
            <li v-for="bucket in aggregation.buckets"
                class="nomargin hiddable pointer"
                :key="aggregation.code + bucket.code"
                @click="toggleFilter(aggregation.code, aggregation.name, bucket.code, bucket.name)"
            >
              <input :class="'color-option' + (isFilterChecked(aggregation.code, bucket.code) ? ' on' : '')"
                     type="button"
                     :aria-label.once="bucket.name"
                     :style.once="'background: ' + bucket.color_code"
              >
              <label class="layered_color"
                     :aria-label="bucket.name"
                     style="cursor: pointer"
              >
                <a data-rel="nofollow" style="cursor: pointer">
                  %% bucket.name %% <span style="cursor: pointer"> (%% bucket.total %%)</span>
                </a>
              </label>
            </li>
          </ul>
          <ul v-else class="layered_filter_ul">
            <li v-for="bucket in aggregation.buckets" class="nomargin hiddable" :key="aggregation.code + bucket.code">
              <div class="checkbox">
                <label>
                  <input type="checkbox"
                         :checked="isFilterChecked(aggregation.code, bucket.code)"
                         @click="toggleFilter(aggregation.code, aggregation.name, bucket.code, bucket.name)"
                  >
                  <a class="pointer"
                     data-rel="nofollow"
                  >
                    %% bucket.name %%<span> (%% bucket.total %%)</span>
                  </a>
                </label>
              </div>
            </li>
          </ul>
        </div>
      </div>
    </div>
  </nav>
</section>
