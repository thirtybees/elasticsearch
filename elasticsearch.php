<?php
/**
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
 */

use Elasticsearch\ClientBuilder;
use ElasticsearchModule\AttributesHelper;
use ElasticsearchModule\IndexStatus;
use ElasticsearchModule\Meta;

if (!defined('_TB_VERSION_')) {
    return;
}

require_once __DIR__.'/vendor/autoload.php';

/**
 * Class Elasticsearch
 */
class Elasticsearch extends Module
{
    // Include ajax functions
    use \ElasticsearchModule\ModuleAjaxTrait;

    const LOGGING_ENABLED = 'ELASTICSEARCH_LOGGING';
    const SERVERS = 'ELASTICSEARCH_SERVERS';
    const METAS = 'ELASTICSEARCH_METAS';
    const INDEX_CHUNK_SIZE = 'ELASTICSEARCH_ICHUNK_SIZE';
    const INDEX_PREFIX = 'ELASTICSEARCH_IPREFIX';
    const SHARDS = 'ELASTICSEARCH_SHARDS';
    const REPLICAS = 'ELASTICSEARCH_REPLICAS';
    const QUERY_JSON = 'ELASTICSEARCH_QUERY_JSON';
    const OVERLAY_DIV = 'ELASTICSEARCH_OVERLAY_DIV';
    const CATEGORY_DIV = 'ELASTICSEARCH_CATEGORY_DIV';

    /** @var \Elasticsearch\Client $readClient */
    protected static $readClient;
    /** @var \Elasticsearch\Client $writeClient */
    protected static $writeClient;
    /**
     * Hooks
     *
     * @var array
     */
    protected $hooks = [
        'displayTop',
        'displayLeftColumn',
        'displayRightColumn',
    ];

    /**
     * ElasticSearch constructor.
     */
    public function __construct()
    {
        $this->version = '1.0.0';
        $this->name = 'elasticsearch';
        $this->author = 'thirty bees';
        $this->tab = 'front_office_features';

        $this->bootstrap = true;

        parent::__construct();

        $this->displayName = $this->l('Elasticsearch');
        $this->description = $this->l('Elasticsearch module for thirty bees');

        $this->controllers = ['search'];
    }

    /**
     * Install this module
     *
     * @return bool
     */
    public function install()
    {
        if (!parent::install()) {
            return false;
        }

        $this->installDB();

        foreach ($this->hooks as $hook) {
            $this->registerHook($hook);
        }

        Configuration::updateGlobalValue(static::INDEX_CHUNK_SIZE, 10);
        Configuration::updateGlobalValue(static::INDEX_PREFIX, 'thirtybees');
        Configuration::updateGlobalValue(static::SHARDS, 3);
        Configuration::updateGlobalValue(static::REPLICAS, 2);
        Configuration::updateGlobalValue(static::QUERY_JSON, file_get_contents(__DIR__.'/data/defaultquery.json'));
        Configuration::updateGlobalValue(static::OVERLAY_DIV, '#columns > .row');
        Configuration::updateGlobalValue(static::CATEGORY_DIV, '#main_column');

        return true;
    }

    /**
     * Uninstall this module
     *
     * @return bool
     */
    public function uninstall()
    {
        Configuration::deleteByName(static::SERVERS);
        Configuration::deleteByName(static::LOGGING_ENABLED);
        Configuration::deleteByName(static::INDEX_CHUNK_SIZE);
        Configuration::deleteByName(static::INDEX_PREFIX);
        Configuration::deleteByName(static::REPLICAS);
        Configuration::deleteByName(static::SHARDS);
        Configuration::deleteByName(static::OVERLAY_DIV);
        Configuration::deleteByName(static::CATEGORY_DIV);

        return parent::uninstall();
    }

    /**
     * @return string
     */
    public function getContent()
    {
        // jQuery + sortable plugin
        $this->context->controller->addJquery();
        $this->context->controller->addJqueryUI('ui.sortable');

        // Module CSS
        $this->context->controller->addCSS($this->_path.'views/css/style.css', 'all');
        $this->context->controller->addCSS($this->_path.'views/css/admin.css', 'all');

        // Bootstrap select
        $this->context->controller->addCSS($this->_path.'views/css/bootstrap-select-1.12.4.min.css', 'screen');
        $this->context->controller->addJS($this->_path.'views/js/bootstrap-select-1.12.4.min.js');

        // SweetAlert 2
        $this->context->controller->addJS($this->_path.'views/js/sweetalert-2.0.6.min.js');

        // ES6 Promises polyfill
        $this->context->controller->addJS($this->_path.'views/js/core-2.4.1.min.js');

        // Lodash
        $this->context->controller->addJS($this->_path.'views/js/lodash-4.17.4.min.js');

        // Ace editor
        $this->context->controller->addJS(_PS_JS_DIR_.'ace/ace.js');
        $this->context->controller->addCSS(_PS_JS_DIR_.'ace/aceinput.css');

        // Vue.js
        $this->context->controller->addJS('https://unpkg.com/vue@2.4.1');
//        $this->context->controller->addJS($this->_path.'views/js/vue-2.4.4.min.js');

        // Vuex
        $this->context->controller->addJS('https://unpkg.com/vuex@2.5.0');
//        $this->context->controller->addJS($this->_path.'views/js/vuex-2.5.0.min.js');

        Media::addJsDef(['elasticAjaxUrl' => $this->context->link->getAdminLink('AdminModules', true)."&configure={$this->name}&tab_module={$this->tab}&module_name={$this->name}"]);
        $this->context->smarty->assign([
            'config'         => $this->getConfigFormValues(),
            'initialTab'     => 'config',
            'status'         => [
                'indexed' => IndexStatus::getIndexed(null, $this->context->shop->id),
                'total'   => (int) IndexStatus::countProducts(),
            ],
            'totalProducts'  => IndexStatus::countProducts($this->context->language->id, $this->context->shop->id),
            'languages'      => Language::getLanguages(false, false, false),
            'tabs'           => [
                [
                    'name' => 'Configuration',
                    'key'  => 'config',
                    'icon' => 'cogs',
                ],
                [
                    'name' => 'Connection',
                    'key'  => 'connection',
                    'icon' => 'plug',
                ],
                [
                    'name' => 'Indexing',
                    'key'  => 'indexing',
                    'icon' => 'sort',
                ],
                [
                    'name' => 'Search',
                    'key'  => 'search',
                    'icon' => 'search',
                ],
                [
                    'name' => 'Filter',
                    'key'  => 'filter',
                    'icon' => 'filter',
                ],
            ],
            'elastic_types' => Meta::getElasticTypes(),
        ]);

        return $this->display(__FILE__, 'views/templates/admin/config/main.tpl');
    }

    /**
     * Display top hook
     *
     * @return string
     */
    public function hookDisplayTop()
    {
        $this->context->controller->addJquery();

        // lodash
        $this->context->controller->addJS($this->_path.'views/js/lodash-4.17.4.min.js');

        // Vue.js
        $this->context->controller->addJS('https://unpkg.com/vue@2.4.1');
//        $this->context->controller->addJS($this->_path.'views/js/vue-2.4.4.min.js');

        // Vuex
        $this->context->controller->addJS('https://unpkg.com/vuex@2.5.0');
//        $this->context->controller->addJS($this->_path.'views/js/vuex-2.5.0.min.js');

        // jQuery Elasticsearch client
        $this->context->controller->addJS($this->_path.'views/js/elasticsearch.jquery-13.3.1.min.js');

        // Autocomplete CSS
        if (file_exists(__DIR__.'views/templates/themes/'.$this->context->shop->theme_name.'/front.css')) {
            $this->context->controller->addCSS(__DIR__.'views/templates/themes/'.$this->context->shop->theme_name.'/front.css');
        } else {
            $this->context->controller->addCSS($this->_path.'views/css/front.css', 'screen');
        }

        // Calculate the conversion to make before displaying prices
        /** @var Currency $defaultCurrency */
        $defaultCurrency = Currency::getCurrencyInstance(Configuration::get(' PS_CURRENCY_DEFAULT'));
        /** @var Currency $currentCurrency */
        $currentCurrency = $this->context->currency;
        $conversion = $defaultCurrency->conversion_rate * $currentCurrency->conversion_rate;

        $taxes = TaxRulesGroup::getAssociatedTaxRatesByIdCountry(Context::getContext()->country->id);
        if (!Tax::excludeTaxeOption() && (int) Group::getPriceDisplayMethod($this->context->customer->id_default_group) == PS_TAX_EXC) {
            foreach ($taxes as $tax) {
                $tax['rate'] = 1.000;
            }
        }

        $this->context->smarty->assign([
            'idGroup'            => (int) $this->context->customer->id ?: 1,
            'taxes'              => $taxes,
            'currencyConversion' => (float) $conversion,
        ]);

        $metas = Meta::getAllMetas()[$this->context->language->id];
        $aggegrations = [];
        foreach ($metas as $meta) {
            if (!$meta['aggregatable']) {
                continue;
            }

            // Name of the aggregation is the display name - the actual code should be retrieved from the top hit
            $aggegrations[$meta['name']] = [
                // Aggregate on the special aggregate field
                'terms' => [
                    'field' => $meta['code'].'_agg',
                ],
                // This part is added to get the actual display name and meta code of the filter value
                'aggs'  => [
                    'name'       => ['top_hits' => ['size' => 1, '_source' => ['include' => [$meta['code']]]]],
                    'color_code' => ['top_hits' => ['size' => 1, '_source' => ['include' => ["{$meta['code']}_color_code"]]]],
                ],
            ];
        }

        // TODO: find the mandatory fields
        $sources = [];
        foreach ($metas as $meta) {
            if (!$meta['aggregatable'] && !$meta['searchable'] && !in_array($meta['code'], [
                'name',
                'price_tax_excl',
                'id_tax_rules_group',
            ])) {
                continue;
            }

            $sources[] = $meta['code'];
        }

        $this->context->smarty->assign([
            'autocomplete' => true,
            'shop'         => $this->context->shop,
            'language'     => $this->context->language,
            'aggregations' => $aggegrations,
            'sources'      => $sources,
            'metas'        => $metas,
        ]);

        return $this->display(__FILE__, 'displaytop.tpl');
    }

    /**
     * Display left column
     *
     * @return string
     */
    public function hookDisplayLeftColumn()
    {
        return '<div id="elasticsearch-column-left" v-cloak></div>';
    }

    /**
     * Display right column
     *
     * @return string
     */
    public function hookDisplayRightColumn()
    {
        return '<div id="elasticsearch-column-right" v-cloak></div>';
    }

    /**
     * Get read hosts
     *
     * @return array
     */
    public static function getReadHosts()
    {
        $readHosts = [];
        foreach ((array) json_decode(Configuration::get(static::SERVERS), true) as $host) {
            if ($host['read']) {
                $readHosts[] = $host['url'];
            }
        }

        return $readHosts;
    }

    /**
     * Get ElasticSearch Client
     *
     * @return \Elasticsearch\Client|null
     *
     * @throws \Exception
     */
    public static function getReadClient()
    {
        if (!isset(static::$readClient)) {
            try {
                $client = ClientBuilder::create()
                    ->setHosts(static::getReadHosts())
                    ->build();

                // Check connection, throws an exception if something's wrong
                $client->cluster()->stats();

                static::$readClient = $client;
            } catch (Exception $e) {
                return null;
            }
        }

        return static::$readClient;
    }

    /**
     * Get write hosts
     *
     * @return array
     */
    public static function getWriteHosts()
    {
        $writeHosts = [];
        foreach ((array) json_decode(Configuration::get(static::SERVERS), true) as $host) {
            if ($host['write']) {
                $writeHosts[] = $host['url'];
            }
        }

        return $writeHosts;
    }

    /**
     * Get ElasticSearch Client
     *
     * @return \Elasticsearch\Client|null
     *
     * @throws \Exception
     */
    public static function getWriteclient()
    {
        if (!isset(static::$writeClient)) {
            try {
                $client = ClientBuilder::create()
                    ->setHosts(static::getWriteHosts())
                    ->build();

                // Check connection, throws an exception if something's wrong
                $client->cluster()->stats();

                static::$writeClient = $client;
            } catch (Exception $e) {
                return null;
            }

        }

        return static::$writeClient;
    }

    /**
     * Return the location of a template file
     * Search order is as follows for front office and hook templates:
     * - theme-specific templates in current theme dir
     * - theme-specific templates in this module's dir
     * - generic templates in this module's dir
     *
     * Search order for back office templates:
     * - generic templates in this module's dir
     *
     * NOTE: relative path should always be *NIX style, preferably without a leading slash
     *
     * @param string $relativePath
     *
     * @return string
     *
     * @throws Exception
     *
     * @todo: use the built-in caching system among requests, file_exists lookups can cause heavy IO
     */
    public static function tpl($relativePath)
    {
        $themeBaseDir = _PS_THEME_DIR_.'modules/elasticsearch/';
        $modThemeBaseDir = __DIR__.'views/templates/themes/'.Context::getContext()->shop->theme_name.'/';
        $modDir = __DIR__.'/views/templates/';

        // Search for a theme-specific file
        if (in_array(substr($relativePath, 0, 5), ['hook/', 'front'])) {
            foreach ([$themeBaseDir, $modThemeBaseDir, $modDir] as $basePath) {
                if (file_exists($basePath.$relativePath)) {
                    return $basePath.$relativePath;
                }
            }
        } else {
            if (file_exists($modDir.$relativePath)) {
                return $modDir.$relativePath;
            }
        }

        throw new Exception("Unable to find Elasticsearch template file `$relativePath`");
    }

    /**
     * @param string $query
     *
     * @return string
     */
    public static function jsonEncodeQuery($query)
    {
        return str_replace("\n", '', $query);
    }

    /**
     * Install the database tables for this module
     *
     * @return bool
     */
    protected function installDB()
    {
        if (!file_exists(__DIR__.'/sql/install.sql')) {
            return false;
        } elseif (!$sql = file_get_contents(__DIR__.'/sql/install.sql')) {
            return false;
        }
        $sql = str_replace(['PREFIX_', 'ENGINE_TYPE'], [_DB_PREFIX_, _MYSQL_ENGINE_], $sql);
        $sql = preg_split("/;\s*[\r\n]+/", trim($sql));

        foreach ($sql as $query) {
            if (!Db::getInstance()->execute(trim($query))) {
                return false;
            }
        }

        return true;
    }

    /**
     * @return array
     */
    protected function getConfigFormValues()
    {
        return [
            static::LOGGING_ENABLED => (int) Configuration::get(static::LOGGING_ENABLED),
            static::SERVERS         => (array) json_decode(Configuration::get(static::SERVERS), true),
            static::SHARDS          => (int) Configuration::get(static::SHARDS),
            static::REPLICAS        => (int) Configuration::get(static::REPLICAS),
            static::METAS           => Meta::getAllAttributes(),
            static::INDEX_PREFIX    => Configuration::get(static::INDEX_PREFIX),
            static::QUERY_JSON      => Configuration::get(static::QUERY_JSON),
            static::OVERLAY_DIV     => Configuration::get(static::OVERLAY_DIV),
            static::CATEGORY_DIV    => Configuration::get(static::CATEGORY_DIV),
        ];
    }

    /**
     * Get ElasticSearch version
     *
     * @return string
     */
    protected function getElasticVersion()
    {
        try {
            $client = static::getWriteclient();
        } catch (\Exception $e) {
            if (isset($this->context->employee->id) && $this->context->employee->id) {
                $error = strip_tags($e->getMessage());
                $this->context->controller->errors[] = sprintf($this->l('Unable to initialize Elasticsearch: %s'), $error);
            }
        }

        if (isset($client) && isset($client->cluster()->stats()['nodes']['versions'])) {
            return (string) min($client->cluster()->stats()['nodes']['versions']);
        }

        return $this->l('Unknown');
    }
}
