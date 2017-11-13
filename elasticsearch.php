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

use Elasticsearch\Client;
use Elasticsearch\ClientBuilder;
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
    const PROXY = 'ELASTICSEARCH_PROXY';
    const METAS = 'ELASTICSEARCH_METAS';
    const INDEX_CHUNK_SIZE = 'ELASTICSEARCH_ICHUNK_SIZE';
    const INDEX_PREFIX = 'ELASTICSEARCH_IPREFIX';
    const SHARDS = 'ELASTICSEARCH_SHARDS';
    const REPLICAS = 'ELASTICSEARCH_REPLICAS';
    const QUERY_JSON = 'ELASTICSEARCH_QUERY_JSON';
    const OVERLAY_DIV = 'ELASTICSEARCH_OVERLAY_DIV';
    const PRODUCT_LIST = 'ELASTICSEARCH_PRODUCT_LIST';
    const DEFAULT_TAX_RULES_GROUP = 'ELASTICSEARCH_ID_TAX_RULES';
    const INFINITE_SCROLL = 'ELASTICSEARCH_INFINITE_SCROLL';
    const STOP_WORDS = 'ELASTICSEARCH_STOP_WORDS';
    const BLACKLISTED_FIELDS = 'ELASTICSEARCH_BLACKLISTED_FIELDS';

    /** @var array $stopWordLangs */
    public static $stopWordLangs = [
        'ar' => '_arabic_',
        'am' => '_armenian_',
        'eu' => '_basque_',
        'br' => '_brazilian_',
        'bg' => '_bulgarian_',
        'ca' => '_catalan_',
        'cs' => '_czech_',
        'da' => '_danish_',
        'nl' => '_dutch_',
        'en' => '_english_',
        'gb' => '_english_',
        'fi' => '_finnish_',
        'fr' => '_french_',
        'gl' => '_galician_',
        'de' => '_german_',
        'el' => '_greek_',
        'hi' => '_hindi_',
        'hu' => '_hungarian_',
        'id' => '_indonesian_',
        'ga' => '_irish_',
        'it' => '_italian_',
        'lv' => '_latvian_',
        'no' => '_norwegian_',
        'fa' => '_persian_',
        'pt' => '_portuguese_',
        'ro' => '_romanian_',
        'ru' => '_russian_',
        'es' => '_spanish_',
        'se' => '_swedish_',
        'th' => '_thai_',
        'tr' => '_turkish_',
    ];

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
        if (version_compare(phpversion(), '5.6', '<')) {
            Context::getContext()->controller->errors[] = sprintf($this->l('The Elasticsearch module requires at least PHP version 5.6. Your current version is: %s'), phpversion());
        }

        if (!parent::install()) {
            return false;
        }

        $this->installDB();

        foreach ($this->hooks as $hook) {
            $this->registerHook($hook);
        }

        Configuration::updateGlobalValue(static::INDEX_CHUNK_SIZE, 10);
        Configuration::updateGlobalValue(static::INDEX_PREFIX, 'thirtybees');
        Configuration::updateGlobalValue(static::PROXY, true);
        Configuration::updateGlobalValue(static::SHARDS, 3);
        Configuration::updateGlobalValue(static::REPLICAS, 2);
        Configuration::updateGlobalValue(static::QUERY_JSON, file_get_contents(__DIR__.'/data/defaultquery.json'));
        Configuration::updateGlobalValue(static::OVERLAY_DIV, '#main_column, #center_column');
        Configuration::updateGlobalValue(static::BLACKLISTED_FIELDS, 'pageviews, sales');
        $defaultTaxGroup = 0;
        $taxes = TaxRulesGroup::getTaxRulesGroups(true);
        if (!empty($taxes)) {
            $defaultTaxGroup = $taxes[0][TaxRulesGroup::$definition['primary']];
        }
        Configuration::updateGlobalValue(static::DEFAULT_TAX_RULES_GROUP, $defaultTaxGroup);

        foreach (Shop::getShops(false) as $shop) {
            $stopWords = [];

            foreach (Language::getLanguages(false) as $language) {
                $stopWords[(int) $language['id_lang']] = static::getStopWordLang(strtolower($language['iso_code']));
            }

            Configuration::updateValue(static::STOP_WORDS, $stopWords, false, (int) $shop['id_shop_group'], (int) $shop['id_shop']);
        }

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
        Configuration::deleteByName(static::PROXY);
        Configuration::deleteByName(static::LOGGING_ENABLED);
        Configuration::deleteByName(static::INDEX_CHUNK_SIZE);
        Configuration::deleteByName(static::INDEX_PREFIX);
        Configuration::deleteByName(static::REPLICAS);
        Configuration::deleteByName(static::SHARDS);
        Configuration::deleteByName(static::OVERLAY_DIV);
        Configuration::deleteByName(static::DEFAULT_TAX_RULES_GROUP);

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
                'total'   => (int) IndexStatus::countProducts(null, $this->context->shop->id),
            ],
            'totalProducts'  => IndexStatus::countProducts($this->context->language->id, $this->context->shop->id),
            'languages'      => Language::getLanguages(false, false, false),
            'tabGroups' => [
                [
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
                ],
                [
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
                [
                    [
                        'name' => 'Display',
                        'key'  => 'display',
                        'icon' => 'desktop',
                    ],
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
        // lodash
        $this->context->controller->addJS($this->_path.'views/js/lodash-4.17.4.min.js');

        // Vue.js
        $this->context->controller->addJS('https://unpkg.com/vue@2.4.4');
//        $this->context->controller->addJS($this->_path.'views/js/vue-2.4.4.min.js');

        if (Configuration::get(static::INFINITE_SCROLL)) {
            $this->context->controller->addJS('https://unpkg.com/vue-infinite-loading');
        }

        // Vuex
        $this->context->controller->addJS('https://unpkg.com/vuex@2.5.0');
//        $this->context->controller->addJS($this->_path.'views/js/vuex-2.5.0.min.js');

        // Elasticsearch client
        $this->context->controller->addJS($this->_path.'views/js/elasticsearch.13.3.1.min.js');

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
        if (!Tax::excludeTaxeOption() && (int) Group::getPriceDisplayMethod($this->context->customer->id_default_group) === PS_TAX_EXC) {
            foreach ($taxes as &$tax) {
                $tax['rate'] = 1.000;
            }
        }

        $defaultTax = 1.0000;
        if (isset($taxes[Configuration::get(static::DEFAULT_TAX_RULES_GROUP)])) {
            $defaultTax = 1 + (float) $taxes[Configuration::get(static::DEFAULT_TAX_RULES_GROUP)] / 100;
        }

        $this->context->smarty->assign([
            'idGroup'            => (int) $this->context->customer->id_default_group ?: 1,
            'defaultTax'         => $defaultTax,
            'taxes'              => $taxes,
            'currencyConversion' => (float) $conversion,
        ]);

        $metas = Meta::getAllMetas([$this->context->language->id]);
        if (isset($metas[$this->context->language->id])) {
            $metas = $metas[$this->context->language->id];
        }

        $aggegrations = [];
        foreach ($metas as $meta) {
            if (!$meta['aggregatable']) {
                continue;
            }

            // If meta is a slider (display_type = slider/4), then pick the min and max value
            if ((int) $meta['display_type'] === 4) {
                $aggegrations["{$meta['code']}_min"] = [
                    'min'  => [
                        'field' => $meta['code'].'_group_'.(int) Context::getContext()->customer->id_default_group,
                    ],
                    'meta' => [
                        'name'            => $meta['name'],
                        'code'            => "{$meta['code']}_min",
                        'slider_code'     => $meta['code'],
                        'slider_agg_code' => $meta['code'].'_group_'.(int) Context::getContext()->customer->id_default_group,
                        'position'        => $meta['position'],
                        'display_type'    => $meta['display_type'],
                    ],
                ];
                $aggegrations["{$meta['code']}_max"] = [
                    'max'  => [
                        'field' => $meta['code'].'_group_'.(int) Context::getContext()->customer->id_default_group,
                    ],
                    'meta' => [
                        'name'            => $meta['name'],
                        'code'            => "{$meta['code']}_max",
                        'slider_code'     => $meta['code'],
                        'slider_agg_code' => $meta['code'].'_group_'.(int) Context::getContext()->customer->id_default_group,
                        'position'        => $meta['position'],
                        'display_type'    => $meta['display_type'],
                    ],
                ];

                continue;
            }

            // Pick the meta value and code (via _agg)
            $aggs  = [
                'name' => ['top_hits' => ['size' => 1, '_source' => ['includes' => [$meta['code']]]]],
                'code' => ['top_hits' => ['size' => 1, '_source' => ['includes' => ["{$meta['code']}_agg"]]]],
            ];

            // If meta is a color (display_type = color/5), then pick the color code as well
            if ((int) $meta['display_type'] === 5) {
                $aggs['color_code'] = ['top_hits' => ['size' => 1, '_source' => ['includes' => ["{$meta['code']}_color_code"]]]];
            }

            // Name of the aggregation is the display name - the actual code should be retrieved from the top hit
            $aggegrations[$meta['code']] = [
                // Aggregate on the special aggregate field
                'terms' => [
                    'field' => $meta['code'].'_agg',
                    'size'  => (int) $meta['result_limit'] ?: 10000,
                ],
                // This part is added to get the actual display name and meta code of the filter value
                'aggs'  => $aggs,
                'meta' => [
                    'name'         => $meta['name'],
                    'code'         => $meta['code'],
                    'position'     => $meta['position'],
                    'display_type' => $meta['display_type'],
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
     * Get ElasticSearch Client with read access
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
     * Get ElasticSearch Client with write access
     *
     * @return \Elasticsearch\Client|null
     *
     * @throws \Exception
     */
    public static function getWriteClient()
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
                $context = Context::getContext();
                if (isset($context->employee->id) && $context->employee->id) {
                    $context->controller->errors[] = $e->getMessage();
                }

                return null;
            }

        }

        return static::$writeClient;
    }

    /**
     * Get frontend hosts
     *
     * @return array
     */
    public static function getFrontendHosts()
    {
        if (Configuration::get(static::PROXY)) {
            return [Context::getContext()->link->getModuleLink('elasticsearch', 'proxy', [], Tools::usingSecureMode())];
        }

        return static::getReadHosts();
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
     * Get stop word lang array for the given iso code
     *
     * @param string $isoCode
     *
     * @return mixed
     */
    public static function getStopWordLang($isoCode)
    {
        if (isset(static::$stopWordLangs[$isoCode])) {
            return static::$stopWordLangs[$isoCode];
        }

        return static::$stopWordLangs['en'];
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
     * Index remaining products
     *
     * @param int $chunks
     * @param int $idShop
     */
    public function cronProcessRemainingProducts($chunks, $idShop)
    {
        /** @var Client $client */
        $client = static::getWriteClient();
        if (!$client) {
            die(json_encode([
                'success' => false,
            ]));
        }
        $amount = (int) (Configuration::get(static::INDEX_CHUNK_SIZE) ?: 100);
        if (!$amount) {
            $amount = 100;
        }
        $index = Configuration::get(Elasticsearch::INDEX_PREFIX);
        $idLang = Context::getContext()->language->id;
        $metas = Meta::getAllMetas([$idLang]);
        if (isset($metas[$idLang])) {
            $metas = $metas[$idLang];
        }

        while ($chunks > 0) {
            // Check which products are available for indexing
            $products = IndexStatus::getProductsToIndex($amount, 0, null, $idShop);

            if (empty($products)) {
                // Nothing to index -- cron job done
                exit(0);
            }

            $params = [
                'body' => [],
            ];
            foreach ($products as &$product) {
                $params['body'][] = [
                    'index' => [
                        '_index' => "{$index}_{$idShop}_{$product->id_lang}",
                        '_type'  => 'product',
                        '_id'    => $product->id,
                    ],
                ];

                // Process prices for customer groups
                foreach ($product->price_tax_excl as $group => $value) {
                    $product->{"price_tax_excl_{$group}"} = $value;
                }
                unset($product->price_tax_excl);

                // Make aggregatable copies of the properties
                // These need to be `link_rewrite`d to make sure they can fit a the friendly URL
                foreach (get_object_vars($product) as $name => $var) {
                    // Do not create an aggregatable copy for color codes
                    // Color codes are meta data for aggregations
                    if (substr($name, -11) === '_color_code') {
                        continue;
                    }

                    if (isset($metas[$name]) && in_array($metas[$name]['elastic_type'], ['string', 'text'])) {
                        if (is_array($var)) {
                            foreach ($var as &$item) {
                                $item = Tools::link_rewrite($item);
                            }
                        } else {
                            $var = Tools::link_rewrite($var);
                        }
                    }

                    $product->{$name.'_agg'} = $var;
                }

                $params['body'][] = $product;
            }

            // Push to Elasticsearch
            try {
                $results = $client->bulk($params);
            } catch (Exception $exception) {
                exit(1);
            }
            $failed = [];
            foreach ($results['items'] as $result) {
                if ((int) substr($result['index']['status'], 0, 1) !== 2) {
                    preg_match('/(?P<index>[a-zA-Z]+)\_(?P<id_shop>\d+)\_(?P<id_lang>\d+)/', $result['index']['_index'], $details);
                    $failed[] = [
                        'id_lang'    => (int) $details['id_lang'],
                        'id_shop'    => (int) $details['id_shop'],
                        'id_product' => (int) $result['index']['_id'],
                        'error'      => isset($result['index']['error']['reason']) ? $result['index']['error']['reason'].(isset($result['index']['error']['caused_by']['reason']) ? ' '.$result['index']['error']['caused_by']['reason'] : '') : 'Unknown error',
                    ];
                }
            }
            if (!empty($failed)) {
                foreach ($failed as $failure) {
                    foreach ($products as $index => $product) {
                        if ((int) $product->id === (int) $failure['id_product']
                            && (int) $product->id_shop === (int) $failure['id_shop']
                            && (int) $product->id_lang === (int) $failure['id_lang']
                        ) {
                            Db::getInstance()->execute('INSERT INTO `'._DB_PREFIX_."elasticsearch_index_status` (`id_product`,`id_lang`,`id_shop`, `error`) VALUES ('{$failed['id_product']}', '{$failed['id_lang']}', '{$failed['id_shop']}', '{$failed['error']}') ON DUPLICATE KEY UPDATE `error` = VALUES(`error`)");

                            unset($products[$index]);
                        }
                    }
                }
            }

            // Insert index status into database
            $values = '';
            foreach ($products as &$product) {
                $values .= "('{$product->id}', '{$product->id_lang}', '{$this->context->shop->id}', '{$product->date_upd}', ''),";
            }
            $values = rtrim($values, ',');
            if ($values) {
                Db::getInstance()->execute('INSERT INTO `'._DB_PREFIX_."elasticsearch_index_status` (`id_product`,`id_lang`,`id_shop`, `date_upd`, `error`) VALUES $values ON DUPLICATE KEY UPDATE `date_upd` = VALUES(`date_upd`), `error` = ''");
            }

            $chunks--;
        }

        exit(0);
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
        $stopWords = [];
        foreach (Language::getLanguages(true) as $language) {
            $idLang = (int) $language['id_lang'];
            $stopWords[$idLang] = (string) Configuration::get(static::STOP_WORDS, $idLang);
        }

        return [
            static::LOGGING_ENABLED         => (int) Configuration::get(static::LOGGING_ENABLED),
            static::PROXY                   => (int) Configuration::get(static::PROXY),
            static::SERVERS                 => (array) json_decode(Configuration::get(static::SERVERS), true),
            static::SHARDS                  => (int) Configuration::get(static::SHARDS),
            static::REPLICAS                => (int) Configuration::get(static::REPLICAS),
            static::METAS                   => Meta::getAllAttributes(),
            static::INDEX_PREFIX            => Configuration::get(static::INDEX_PREFIX),
            static::QUERY_JSON              => Configuration::get(static::QUERY_JSON),
            static::OVERLAY_DIV             => Configuration::get(static::OVERLAY_DIV),
            static::PRODUCT_LIST            => Configuration::get(static::PRODUCT_LIST),
            static::DEFAULT_TAX_RULES_GROUP => Configuration::get(static::DEFAULT_TAX_RULES_GROUP),
            static::STOP_WORDS              => $stopWords,
            static::BLACKLISTED_FIELDS      => Configuration::get(static::BLACKLISTED_FIELDS),
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
            $client = static::getWriteClient();
        } catch (Exception $e) {
            $context = Context::getContext();
            if (isset($context->employee->id) && $context->employee->id) {
                $context->controller->errors[] = sprintf(
                    $this->l('Unable to initialize Elasticsearch: %s'),
                    strip_tags($e->getMessage())
                );
            }
        }

        if (isset($client)) {
            try {
                $stats = $client->cluster()->stats();

                if (isset($stats['nodes']['versions'])) {
                    $clusterStats = $client->cluster()->stats();

                    return (string) min($clusterStats['nodes']['versions']);
                }
            } catch (Exception $e) {
                $context = Context::getContext();
                if (isset($context->employee->id) && $context->employee->id) {
                    $context->controller->errors[] = sprintf(
                        $this->l('Unable to initialize Elasticsearch: %s'),
                        strip_tags($e->getMessage())
                    );
                }
            }
        }

        return $this->l('Unknown');
    }
}
