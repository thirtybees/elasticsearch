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

namespace ElasticsearchModule;

use Configuration;
use Context;
use Db;
use Elasticsearch;
use Elasticsearch\Client;
use Exception;
use ReflectionClass;
use Tools;

if (!defined('_TB_VERSION_')) {
    return;
}

/**
 * Trait ModuleAjaxTrait
 *
 * @package ElasticsearchModule
 */
trait ModuleAjaxTrait
{
    // FRONT OFFICE


    // BACK OFFICE
    /**
     * Ajax process save module settings
     */
    public function ajaxProcessSaveSettings()
    {
        header('Content-Type: application/json; charset=utf-8');
        $settings = json_decode(file_get_contents('php://input'), true);
        $idShop = Context::getContext()->shop->id;

        // Figure out which setting keys are available (constants from the main class)
        /** @var ReflectionClass $reflect */
        $reflect = new ReflectionClass($this);
        $consts = $reflect->getConstants();
        foreach ($settings as $setting => $value) {
            if (in_array($setting, $consts)) {
                if ($setting === static::METAS) {
                    Meta::saveMetas($value);
                    continue;
                } elseif ($setting == static::SERVERS) {
                    if ($settings[static::PROXY]) {
                        foreach ($value as &$server) {
                            $server['read'] = 1;
                            $server['write'] = 1;
                        }
                    }
                    $value = json_encode($value);
                } elseif (is_array($value)) {
                    $value = json_encode($value);
                }

                Configuration::updateValue($setting, $value);
            }
        }

        try {
            // Save settings in Elasticsearch

            // Delete the indices first
            Indexer::eraseIndices(null, [$idShop]);

            // Reset the mappings
            Indexer::createMappings(null, [$idShop]);

            // Reset the local index status for the current shop
            IndexStatus::erase($idShop);
        } catch (Exception $e) {
            // Don't crash if we cannot connect
        }

        // Reponse status
        die(json_encode([
            'success' => true,
            'indexed' => 0,
            'total'   => (int) IndexStatus::countProducts(null, $this->context->shop->id),
        ]));
    }

    /**
     * Index remaining products
     */
    public function ajaxProcessIndexRemaining()
    {
        header('Content-Type: application/json; charset=utf-8');
        /** @var Client $client */
        $client = static::getWriteClient();
        if (!$client) {
            die(json_encode([
                'success' => false,
            ]));
        }
        $input = json_decode(file_get_contents('php://input'), true);
        $amount = (int) (isset($input['amount']) ? (int) $input['amount'] : Configuration::get(static::INDEX_CHUNK_SIZE));
        if (!$amount) {
            $amount = 10;
        }
        $index = Configuration::get(Elasticsearch::INDEX_PREFIX);
        $idShop = Context::getContext()->shop->id;
        $idLang = Context::getContext()->language->id;
        $metas = Meta::getAllMetas([$idLang]);
        if (isset($metas[$idLang])) {
            $metas = $metas[$idLang];
        }

        // Check which products are available for indexing
        $products = IndexStatus::getProductsToIndex($amount, 0, null, $this->context->shop->id);

        if (empty($products)) {
            // Nothing to index
            die(json_encode([
                'success'  => true,
                'indexed'  => IndexStatus::getIndexed(null, $this->context->shop->id),
                'total'    => (int) IndexStatus::countProducts(null, $this->context->shop->id),
                'nbErrors' => 0,
                'errors'   => [],
            ]));
        }

        $params = [
            'body' => [],
        ];
        foreach ($products as &$product) {
            $params['body'][] = [
                'index' => [
                    '_index' => "{$index}_{$idShop}_{$product->id_lang}",
                    '_type'  => 'product',
                    '_id'     => $product->id,
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
            die(json_encode([
                'success' => false,
            ]));
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
            $values .=  "('{$product->id}', '{$product->id_lang}', '{$this->context->shop->id}', '{$product->date_upd}', ''),";
        }
        $values = rtrim($values, ',');
        if ($values) {
            Db::getInstance()->execute('INSERT INTO `'._DB_PREFIX_."elasticsearch_index_status` (`id_product`,`id_lang`,`id_shop`, `date_upd`, `error`) VALUES $values ON DUPLICATE KEY UPDATE `date_upd` = VALUES(`date_upd`), `error` = ''");
        }

        // Response status
        die(json_encode([
            'success'  => true,
            'indexed'  => IndexStatus::getIndexed(null, $this->context->shop->id),
            'total'    => (int) IndexStatus::countProducts(null, $this->context->shop->id),
            'nbErrors' => count($failed),
            'errors'   => $failed,
        ]));
    }

    /**
     * Ajax process erase index
     */
    public function ajaxProcessEraseIndex()
    {
        header('Content-Type: application/json; charset=utf-8');
        $idShop = Context::getContext()->shop->id;

        try {
            // Delete the indices first
            Indexer::eraseIndices(null, [$idShop]);

            // Reset the mappings
            Indexer::createMappings(null, [$idShop]);

            // Erase the index status for the current store
            IndexStatus::erase($idShop);
        } catch (Exception $e) {
        }

        // Response status
        die(json_encode([
            'success' => true,
            'indexed' => IndexStatus::getIndexed(null, $idShop),
            'total'   => (int) IndexStatus::countProducts(null, $idShop),
        ]));
    }

    /**
     * @return void
     */
    public function ajaxProcessGetElasticsearchVersion()
    {
        header('Content-Type: application/json; charset=utf-8');
        die(json_encode([
            'version' => $this->getElasticVersion(),
            'errors'  => $this->context->controller->errors,
        ]));
    }
}
