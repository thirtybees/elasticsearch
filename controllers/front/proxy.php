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

if (!defined('_TB_VERSION_')) {
    exit;
}

/**
 * Class ElasticsearchproxyModuleFrontController
 *
 * Proxy class in order to proxy the frontend widget's calls to a private Elasticsearch server
 */
class ElasticsearchproxyModuleFrontController extends ModuleFrontController
{
    /** @var Elasticsearch $module */
    public $module;
    /** @var \Elasticsearch\Client $client */
    protected $client;

    /**
     * It should just process the ajax call, then die
     *
     * @return void
     */
    public function initContent()
    {
        if ($this->ajax) {
            // Set the content type and access control headers of the response
            header('Content-Type: application/json; charset=UTF-8');
            header('access-control-allow-headers: Access-Control-Allow-Headers,Origin,Accept,X-Requested-With,Content-Type,Access-Control-Request-Method,Access-Control-Request-Headers,Authorization');
            header('access-control-allow-methods:GET,HEAD,OPTIONS,POST,PUT');
            header('access-control-allow-origin: *');

            // Prepare the Elasticsearch client -- every action should be read
            $this->client = Elasticsearch::getWriteClient();
            if (!$this->client) {
                die(json_encode([
                    'success' => false,
                    'messages' => ['Unable to initialize the Elasticsearch client'],
                ]));
            }

            $action = Tools::getValue('action');
            // no need to use displayConf() here
            if (!empty($action) && method_exists($this, 'ajaxProcess'.Tools::toCamelCase($action))) {
                Hook::exec('actionAdmin'.ucfirst($action).'Before', ['controller' => $this]);
                Hook::exec('action'.get_class($this).ucfirst($action).'Before', ['controller' => $this]);

                $return = $this->{'ajaxProcess'.Tools::toCamelCase($action)}();

                Hook::exec('actionAdmin'.ucfirst($action).'After', ['controller' => $this, 'return' => $return]);
                Hook::exec('action'.get_class($this).ucfirst($action).'After', ['controller' => $this, 'return' => $return]);

                die(json_encode($return, JSON_UNESCAPED_SLASHES));
            }

        }

        die();
    }

    /**
     * Do a search
     *
     * Params:
     * - `query`
     *
     *
     * @return array Results or errors
     */
    public function ajaxProcessSearch()
    {
        $idShop = (int) Context::getContext()->shop->id;
        $idLang = (int) Context::getContext()->language->id;
        $query = Tools::getValue('query');
        $matches = (string) Tools::getValue('matches');
        // TODO: figure out a good default value
        $size = (int) (Tools::getValue('size') ? Tools::getValue('size') : 12);
        $from = (int) Tools::getValue('from');
        // FIXME: make it dynamic
        $fields = ['name', 'reference', 'description'];

        $baseJson = Configuration::get(ElasticSearch::QUERY_JSON);
        $baseJson = str_replace('||QUERY||', '"query": "'.$query.'"', $baseJson);
        $baseJson = str_replace('||FIELDS||', '"fields": ["'.implode('","', $fields).'"]', $baseJson);
        $baseJson = str_replace('||MATCHES_APPEND||', ($matches ? ','.$matches : ''), $baseJson);
        $baseJson = str_replace('||MATCHES_PREPEND||', ($matches ? $matches.',' : ''), $baseJson);
        $baseJson = str_replace('||MATCHES_STANDALONE||', ($matches ? $matches : ''), $baseJson);

        // FIXME: base this on the advanced query config
        $results = $this->client->search([
            'index' => Configuration::get(Elasticsearch::INDEX_PREFIX)."_{$idShop}_{$idLang}",
            'type'  => 'product',
            'body'  => [
                'size'  => (int) $size,
                'from'  => (int) $from,
                'query' => json_decode($baseJson, true),
            ],
        ]);

        return $results;
    }
}
