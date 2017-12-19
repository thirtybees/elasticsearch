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
<div ref="wrap"
     :class="['vue-slider-component', flowDirection, disabledClass, { 'vue-slider-has-label': piecewiseLabel }]"
     v-show="show" :style="wrapStyles" @click="wrapClick">
  <div ref="elem" aria-hidden="true" class="vue-slider" :style="[elemStyles, bgStyle]">
    <template v-if="isRange">
      <div ref="dot0"
           :class="[tooltipStatus, 'vue-slider-dot']"
           :style="[dotStyles, sliderStyles[0]]"
           @mousedown="moveStart($event, 0)"
           @touchstart="moveStart($event, 0)"
      >
        <span :class="['vue-slider-tooltip-' + tooltipDirection[0], 'vue-slider-tooltip-wrap']">
            <slot name="tooltip" :value="val[0]" :index="0">
              <span class="vue-slider-tooltip"
                    :style="tooltipStyles[0]">%% formatter ? formatting(val[0]) : val[0] %%</span>
            </slot>
          </span>
      </div>
      <div ref="dot1"
           :class="[tooltipStatus, 'vue-slider-dot']"
           :style="[dotStyles, sliderStyles[1]]"
           @mousedown="moveStart($event, 1)"
           @touchstart="moveStart($event, 1)"
      >
        <span :class="['vue-slider-tooltip-' + tooltipDirection[1], 'vue-slider-tooltip-wrap']">
            <slot name="tooltip" :value="val[1]" :index="1">
              <span class="vue-slider-tooltip"
                    :style="tooltipStyles[1]">%% formatter ? formatting(val[1]) : val[1] %%</span>
            </slot>
        </span>
      </div>
    </template>
    <template v-else>
      <div ref="dot"
           :class="[tooltipStatus, 'vue-slider-dot']"
           :style="[dotStyles, sliderStyles]"
           @mousedown="moveStart"
           @touchstart="moveStart"
      >
        <span :class="['vue-slider-tooltip-' + tooltipDirection, 'vue-slider-tooltip-wrap']">
          <slot name="tooltip" :value="val">
            <span class="vue-slider-tooltip" :style="tooltipStyles">%% formatter ? formatting(val) : val %%</span>
          </slot>
        </span>
      </div>
    </template>
    <ul class="vue-slider-piecewise">
      <li v-for="(piecewiseObj, index) in piecewiseDotWrap" class="vue-slider-piecewise-item"
          :style="[piecewiseDotStyle, piecewiseObj.style]" :key="index">
        <slot name="piecewise"
              :label="piecewiseObj.label"
              :index="index"
              :first="index === 0"
              :last="index === piecewiseDotWrap.length - 1"
        >
          <span v-if="piecewise"
                class="vue-slider-piecewise-dot"
                :style="[ piecewiseStyle, piecewiseObj.inRange ? piecewiseActiveStyle : null ]"
          ></span>
        </slot>

        <slot name="label"
              :label="piecewiseObj.label"
              :index="index"
              :first="index === 0"
              :last="index === piecewiseDotWrap.length - 1"
        >
          <span v-if="piecewiseLabel"
                class="vue-slider-piecewise-label"
                :style="[ labelStyle, piecewiseObj.inRange ? labelActiveStyle : null ]"
          >
            %% piecewiseObj.label %%
          </span>
        </slot>
      </li>
    </ul>
    <div ref="process" class="vue-slider-process" :style="processStyle"></div>
  </div>
  <input v-if="!isRange && !data" class="vue-slider-sr-only" type="range" v-model="val" :min="min" :max="max"/>
</div>
