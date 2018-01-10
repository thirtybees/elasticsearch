<div class="form-group pull-right">
  <label>&nbsp;{l s='Sort by' mod='elasticsearch'}</label>
  <select class="form-control" @change="changeSort">
    <option v-for="sort in sorts" :value="sort.value" :selected="sort.value === selected">%% sort.name %%</option>
  </select>
</div>
