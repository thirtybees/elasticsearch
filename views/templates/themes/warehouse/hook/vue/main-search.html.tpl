{if isset($warehouse_vars.header_style) && ($warehouse_vars.header_style == 2 || $warehouse_vars.header_style == 3)}
  {if isset($blocksearch_type)}
    <div class="elasticsearch-block-top">
      <div class="iqit-search-shower-i"><i class="icon icon-search"></i>{l s='Search' mod='blocksearch_mod'}</div>
      <div id="elasticsearch_block_top" class="search_block_top iqit-search">
        <form method="get" action="{$link->getModuleLink('elasticsearch', 'search', [], true)|escape:'html':'UTF-8'}"
              id="searchbox">
          <input type="hidden" name="controller" value="search"/>
          <input type="hidden" name="orderby" value="position"/>
          <input type="hidden" name="orderway" value="desc"/>

          <div class="search_query_container">
            <input type="hidden" name="search-cat-select" value="0" class="search-cat-select"/>
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
            >
            <button type="submit" name="submit_search" class="button-search">
              <span>{l s='Search' mod='blocksearch_mod'}</span>
            </button>
          </div>
        </form>
      </div>
      <elasticsearch-autocomplete v-if="{if Configuration::get(Elasticsearch::AUTOCOMPLETE)}true{else}false{/if}"
                                  id="elasticsearch-autocomplete"
                                  :results="suggestions"
                                  :selected="selected"
      ></elasticsearch-autocomplete>
    </div>
  {/if}
{else}
<!-- Block search module TOP -->
<div id="search_block_top_content"
     class="col-xs-12 col-sm-{4-$warehouse_vars.logo_width / 2} {if isset($warehouse_vars.logo_position) && !$warehouse_vars.logo_position} col-sm-pull-{4+$warehouse_vars.logo_width} disable_center{/if}">
  <div class="elasticsearch-block-top">
    <div id="elasticsearch_block_top" class="search_block_top {if isset($iqitsearch_text) && $iqitsearch_text !=''}issearchcontent{/if} iqit-search">
      <form method="get" action="{$link->getModuleLink('elasticsearch', 'search', [], true)|escape:'html':'UTF-8'}"
            id="searchbox">
        <input type="hidden" name="controller" value="search"/>
        <input type="hidden" name="orderby" value="position"/>
        <input type="hidden" name="orderway" value="desc"/>

        <div class="search_query_container">
          <input type="hidden" name="search-cat-select" value="0" class="search-cat-select"/>
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
          >
          <button type="submit" name="submit_search" class="button-search">
            <span>{l s='Search' mod='blocksearch_mod'}</span>
          </button>
        </div>
      </form>
    </div>
    <elasticsearch-autocomplete v-if="{if Configuration::get(Elasticsearch::AUTOCOMPLETE)}true{else}false{/if}"
                                id="elasticsearch-autocomplete"
                                :results="suggestions"
                                :selected="selected"
    ></elasticsearch-autocomplete>
  </div>
</div>

{/if}
