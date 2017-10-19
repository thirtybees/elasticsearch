<div class="form-group product-count">
  <p class="form-control-static">
    {l s='Showing' mod='elasticsearch'} %% _.min([offset + 1, total]) %% - %% _.min([page * limit, total]) %% {l s='of' mod='elasticsearch'} %% total %% <span v-if="parseInt(total, 10) === 1">{l s='item' mod='elasticsearch'}</span><span v-else>{l s='items' mod='elasticsearch'}</span>
  </p>
</div>
