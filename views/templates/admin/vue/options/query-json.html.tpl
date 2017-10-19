<div class="form-group">
  <label class="control-label col-lg-3">
    <span class="label-tooltip"
          data-toggle="tooltip"
          title="{l s='This is the full query that will be used, which you can adjust here' mod='elasticsearch'}"
    >
      {l s='Full query' mod='elasticsearch'}
    </span>
  </label>
  <div class="col-lg-9 ace-container">
    <div :id.once="'ace' + configKey" v-once class="ace-editor">%% queryJson %%</div>
  </div>
</div>
