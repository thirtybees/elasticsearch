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
<div id="es-module-page" class="row" v-cloak>
    {include file=ElasticSearch::tpl('admin/config/status.tpl')}
    {include file=ElasticSearch::tpl('admin/config/tabs.tpl')}
    {foreach $tabGroups as $tabGroup}
        {foreach $tabGroup as $tab}
            <div class="col-md-10" v-show="'{$tab['key']}' === currentTab">
                {include file=ElasticSearch::tpl("admin/config/tabs/{$tab.key}.tpl")}
            </div>
        {/foreach}
    {/foreach}
</div>
{include file=ElasticSearch::tpl('admin/vue/loadcomponents.tpl')}
{include file=ElasticSearch::tpl('admin/config/config.store.vue.tpl')}
{include file=ElasticSearch::tpl('admin/config/config.directives.vue.tpl')}
{include file=ElasticSearch::tpl('admin/config/config.vue.tpl')}
