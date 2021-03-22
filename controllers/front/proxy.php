<?php
/**
 * Copyright (C) 2017-2018 thirty bees
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
 * @copyright 2017-2018 thirty bees
 * @license   http://opensource.org/licenses/afl-3.0.php  Academic Free License (AFL 3.0)
 */

use Elasticsearch\Client;

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

    /** @var Client $client */
    protected $client;

    /**
     * It should just process the ajax call, then die
     *
     * @return void
     * @throws PrestaShopException
     */
    public function init()
    {
        if (!empty($_SERVER['HTTP_X_ELASTICSEARCH_PROXY']) && strtolower($_SERVER['HTTP_X_ELASTICSEARCH_PROXY']) == 'magic') {
            // Set the content type and access control headers of the response
            header('Content-Type: application/json; charset=UTF-8');
            header('access-control-allow-headers: Access-Control-Allow-Headers,Origin,Accept,X-Requested-With,Content-Type,Access-Control-Request-Method,Access-Control-Request-Headers,Authorization');
            header('access-control-allow-methods:GET,HEAD,OPTIONS,POST,PUT');
            header('access-control-allow-origin: *');
            // Prepare the Elasticsearch client -- every action should be read
            $this->client = Elasticsearch::getClient();
            if (!$this->client) {
                die(json_encode([
                    'success'  => false,
                    'messages' => ['Unable to initialize the Elasticsearch client'],
                ]));
            }
            // no need to use displayConf() here
            $action = 'elasticsearch';
            Hook::exec('actionAdmin'.ucfirst($action).'Before', ['controller' => $this]);
            Hook::exec('action'.get_class($this).ucfirst($action).'Before', ['controller' => $this]);
            $return = $this->{'ajaxProcess'.Tools::toCamelCase($action)}();
            Hook::exec('actionAdmin'.ucfirst($action).'After', ['controller' => $this, 'return' => $return]);
            Hook::exec('action'.get_class($this).ucfirst($action).'After', ['controller' => $this, 'return' => $return]);
            die(json_encode($return, JSON_UNESCAPED_SLASHES));
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
     * @throws PrestaShopException
     */
    public function ajaxProcessElasticsearch()
    {
        $idShop = (int) Context::getContext()->shop->id;
        $idLang = (int) Context::getContext()->language->id;
        $request = [
            'index' => Configuration::get(Elasticsearch::INDEX_PREFIX)."_{$idShop}_{$idLang}",
            'body'  => json_decode(file_get_contents('php://input')),
        ];

        try {
            return $this->client->search($request);
        } catch (Exception $e) {
            return [];
        }
    }
}
