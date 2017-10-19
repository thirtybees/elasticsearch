<div class="form-group clearfix">
  <ul class="pagination">
    <li id="pagination_previous_bottom" :disabled="page == 1" :class="(page == 1) ? 'disabled ' : '' + 'pagination_previous'" title="Previous">
      <a @click="setPage(page - 1)">
        <span>«</span>
      </a>
    </li>
    <li :class="(page == 1) ? 'active current' : ''">
      <a @click="setPage(1)">
        <span>1</span>
      </a>
    </li>
    <li v-if="nbPages >= 2" :class="(page == 2) ? 'active current' : ''">
      <a @click="setPage(2)">
        <span>2</span>
      </a>
    </li>
    <li v-if="nbPages >= 3 && nbPages < 5" :class="(page == 3) ? 'active current' : ''">
      <a @click="setPage(3)">
        <span>3</span>
      </a>
    </li>
    <li v-if="nbPages > 5" class="truncate">
      <span>
        <span>...</span>
      </span>
    </li>
    <li v-if="nbPages > 5" :class="(page == nbPages - 1) ? 'active current' : ''">
      <a @click="setPage(nbPages - 1)">
        <span>%% nbPages - 1%%</span>
      </a>
    </li>
    <li v-if="nbPages > 5" :class="(page == nbPages) ? 'active current' : ''">
      <a @click="setPage(nbPages)">
        <span>%% nbPages %%</span>
      </a>
    </li>
    <li v-if="nbPages == 4 || nbPages == 5" :class="(page == 4) ? 'active current' : ''">
      <a @click="setPage(4)">
        <span>4</span>
      </a>
    </li>
    <li v-if="nbPages == 5" :class="(page == 5) ? 'active current' : ''">
      <a @click="setPage(5)">
        <span>5</span>
      </a>
    </li>
    <li id="pagination_next_bottom" :disabled="page == nbPages" :class="(page == nbPages) ? 'disabled' : '' + 'pagination_next'" title="Next">
      <a rel="next" @click="setPage(page + 1)">
        <span>»</span>
      </a>
    </li>
  </ul>
</div>
