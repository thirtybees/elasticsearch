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
<div class="panel panel-default">
  <h3><i class="icon icon-search"></i> {l s='Search' mod='elasticsearch'}</h3>
  <div class="form-horizontal form-wrapper">
    <search-meta-list config-key="{Elasticsearch::METAS}"></search-meta-list>
    <div class="alert alert-info">
      <span>{l s='In this section you can customize the query used by the module. There are at least three placeholders you should add (`%s`, `%s` and `%s`)' mod='elasticsearch' sprintf=['QUERY', 'FIELDS', 'FILTERS']}</span>
      <ul>
        <li><code>||QUERY||</code>: {l s='This is the literal query string and will result in e.g.' mod='elasticsearch'} <code>"search query"</code>
        <li><code>||FIELDS||</code>: {l s='This is the fields array of fields to search in. An example is' mod='elasticsearch'} <code>["name", "description"]</code>
        <li><code>||FILTERS||</code>: {l s='This is the filters object of filters to apply. The structure looks like the following:' mod='elasticsearch'} <code>{literal}{"bool":{"must":[{"bool":{"must":{"term":{"color_agg":"red"}}}}]}}{/literal}</code>
      </ul>
    </div>
    <query-json config-key="{ElasticSearch::QUERY_JSON}"></query-json>
  </div>
  <div class="panel-footer">
    <button type="submit" class="btn btn-default pull-right ajax-save-btn" :disabled="!canSubmit"
            @click="submitSettings">
      <i class="process-icon-save"></i> {l s='Save and stay' mod='elasticseach'}
    </button>
  </div>
</div>
