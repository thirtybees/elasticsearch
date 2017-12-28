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
<div id="elasticsearch-autocomplete" v-if="results.length">
  <span :class="'elastic-suggestion clearfix ' + ((result._id == selected) ? 'active' : '')"
        v-for="result in results"
        :key="result._id"
        @click="suggestionClicked(result, $event)"
  >
    <a :href="result._source.link"
       v-if="result.highlight"
       v-html="result.highlight.name[0]"
       @click="suggestionClicked(result, $event)"
    ></a>
    <a :href="result._source.link"
       v-else="result.highlight"
       @click="suggestionClicked(result, $event)"
    >%% result._source.name %%</a>
  </span>
</div>
