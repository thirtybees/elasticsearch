<div class="form-group clearfix">
  <ul class="pagination" style="cursor: pointer">
    <li :disabled="page == 1"
        :class="(page == 1) ? 'disabled ' : '' + 'pagination_previous'"
        title="{l s='First' mod='elasticsearch'}"
    >
      <a @click="setPage(1)">
        <span class="icon icon-angle-double-left"></span>
      </a>
    </li>
    <li :disabled="page == 1"
        :class="(page == 1) ? 'disabled ' : '' + 'pagination_previous'"
        title="{l s='Previous' mod='elasticsearch'}"
    >
      <a @click="setPage(page - 1)">
        <span class="icon icon-angle-left"></span>
      </a>
    </li>
    <li v-for="numberToShow in numbersToShow" :class="(page == numberToShow) ? 'active current' : ''">
      <a @click="setPage(numberToShow)">
        <span>%% numberToShow %%</span>
      </a>
    </li>
    <li :disabled="page == nbPages" :class="(page == nbPages) ? 'disabled' : '' + 'pagination_next'" title="Next">
      <a rel="next" @click="setPage(page + 1)">
        <span class="icon icon-angle-right"></span>
      </a>
    </li>
    <li :disabled="page == nbPages" :class="(page == nbPages) ? 'disabled' : '' + 'pagination_next'" title="Next">
      <a rel="next" @click="setPage(nbPages)">
        <span class="icon icon-angle-double-right"></span>
      </a>
    </li>
  </ul>
</div>
