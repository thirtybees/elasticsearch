{*
 * Copyright (C) 2017 thirty bees
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
 * @copyright 2017 thirty bees
 * @license   http://opensource.org/licenses/afl-3.0.php  Academic Free License (AFL 3.0)
 *}
<div id="elasticsearch-block-top" class="col-sm-4 col-md-5" role="search" v-cloak>
  {* TODO: restore non-js submits *}
  <input type="hidden" name="controller" value="search"/>
  <input type="hidden" name="orderby" value="position"/>
  <input type="hidden" name="orderway" value="desc"/>
  <div class="input-group input-group-lg">
    <input class="form-control"
           type="search"
           id="elasticsearch-query-top"
           name="elasticsearch-query"
           placeholder="{l s='Search' mod='elasticsearch'}"
           spellcheck="false"
           required
           aria-label="{l s='Search our site' mod='elasticsearch'}"
           :value="query"
           @input="queryChangedHandler"
           @keydown.enter="submitHandler"
           @keydown.up="suggestionUpHandler"
           @keydown.down="suggestionDownHandler"
           @focus="focusHandler"
           @blur="blurHandler"
    >
    <span class="input-group-btn">
        <button @click="submitHandler" class="btn btn-primary" type="submit" name="submit-search" title="{l s='Search' mod='elasticsearch'}">
          <i class="icon icon-search"></i></button>
      </span>
  </div>
  <elasticsearch-autocomplete id="elasticsearch-results"
                              :results="suggestions"
                              :selected="selected"
  ></elasticsearch-autocomplete>
</div>
