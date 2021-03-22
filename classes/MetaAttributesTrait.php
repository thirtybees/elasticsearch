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

namespace ElasticsearchModule;

use Configuration;
use Context;
use Db;
use DbQuery;
use Feature;
use Language;
use Logger;
use PrestaShopException;
use Shop;
use Tools;

if (!defined('_TB_VERSION_')) {
    return;
}

/**
 * Class MetaAttributesTrait
 */
trait MetaAttributesTrait
{
    /**
     * Get searchable attributes
     *
     * @return array
     * @throws PrestaShopException
     */
    public static function getSearchableProperties()
    {
        $searchable = [];

        foreach (static::getAllProperties((int)Configuration::get('PS_LANG_DEFAULT')) as $key => $value) {
            if ($value->checked) {
                $searchable[$key] = $value->name;
            }
        }

        return $searchable;
    }

    /**
     * Get all attributes
     *
     * @param int|null $idLang Language ID
     *
     * @return array
     */
    public static function getAllProperties($idLang = null)
    {
        if (!$idLang) {
            $idLang = Context::getContext()->language->id;
        }

        $properties = [];
        $deferredProperties = [];
        $metas = static::getAllMetas();

        $type = 'property';
        foreach (Fetcher::$attributes as $defaultAttributeName => $defaultAttribute) {
            $id = "{$defaultAttributeName}property";
            $position = isset($metas[$idLang][$id]['position']) ? $metas[$idLang][$id]['position'] : 0;
            $name = [];
            try {
                foreach (Language::getLanguages(true, false, true) as $language) {
                    $name[(int)$language] = isset($metas[$language][$id]['name'])
                        ? $metas[$language][$id]['name']
                        : $defaultAttributeName;
                }
            } catch (PrestaShopException $e) {
                Logger::addLog("Elasticsearch module error: {$e->getMessage()}");

                return [];
            }
            $elasticType = isset($metas[$idLang][$id]['elastic_type']) ? $metas[$idLang][$id]['elastic_type'] : 'text';
            if (isset($defaultAttribute['elastic_types'])
                && !in_array($elasticType, $defaultAttribute['elastic_types'])
            ) {
                $elasticType = isset($defaultAttribute['default'])
                    ? $defaultAttribute['default']
                    : $defaultAttribute['elastic_types'][0];
            }

            $property = (object)[
                'meta_type' => $type,
                'alias' => isset($metas[$idLang][$id]['alias']) ? $metas[$idLang][$id]['alias'] : '',
                'code' => $defaultAttributeName,
                'name' => $name,
                'position' => (int)$position,
                'weight' => isset($metas[$idLang][$id]['weight'])
                    ? (float)$metas[$idLang][$id]['weight']
                    : 1,
                'searchable' => (int)isset($metas[$idLang][$id]['searchable'])
                    ? (bool)$metas[$idLang][$id]['searchable']
                    : false,
                'enabled' => isset($metas[$idLang][$id]['enabled'])
                    ? (bool)$metas[$idLang][$id]['enabled']
                    : false,
                'aggregatable' => (int)isset($metas[$idLang][$id]['aggregatable'])
                    ? (bool)$metas[$idLang][$id]['aggregatable']
                    : false,
                'operator' => isset($metas[$idLang][$id]['operator'])
                    ? (int)$metas[$idLang][$id]['operator']
                    : 0,
                'display_type' => isset($metas[$idLang][$id]['display_type'])
                    ? (int)$metas[$idLang][$id]['display_type']
                    : 0,
                'elastic_type' => (string)$elasticType,
                'result_limit' => isset($metas[$idLang][$id]['result_limit'])
                    ? (int)$metas[$idLang][$id]['result_limit']
                    : 0,
                'type_configurable' => isset(Fetcher::$attributes[$defaultAttributeName]['type_configurable'])
                    ? Fetcher::$attributes[$defaultAttributeName]['type_configurable']
                    : false,
                'elastic_types' => isset(Fetcher::$attributes[$defaultAttributeName]['elastic_types'])
                    ? Fetcher::$attributes[$defaultAttributeName]['elastic_types']
                    : null,
                'visible' => isset(Fetcher::$attributes[$defaultAttributeName]['visible'])
                    ? Fetcher::$attributes[$defaultAttributeName]['visible']
                    : true,
            ];
            if ($position) {
                static::addProperty($properties, $property);
            } else {
                $deferredProperties[] = $property;
            }
            unset($property);
        }

        $type = 'feature';
        try {
            foreach (Feature::getFeatures($idLang) as $feature) {
                $id = Tools::link_rewrite($feature['name']);
                $id = "{$id}feature";
                $position = isset($metas[$idLang][$id]['position']) ? $metas[$idLang][$id]['position'] : 0;
                $name = [];
                foreach (Language::getLanguages(true, false, true) as $language) {
                    $name[(int)$language] = isset($metas[$language][$id]['name'])
                        ? $metas[$language][$id]['name']
                        : $feature['name'];
                }
                $code = Tools::link_rewrite($feature['name']);

                $property = (object)[
                    'meta_type' => (string)$type,
                    'code' => (string)$code,
                    'alias' => (string)isset($metas[$idLang][$id]['alias'])
                        ? $metas[$idLang][$id]['alias']
                        : '',
                    'name' => $name,
                    'position' => (int)$position,
                    'weight' => isset($metas[$idLang][$id]['weight'])
                        ? (float)$metas[$idLang][$id]['weight']
                        : 1,
                    'searchable' => isset($metas[$idLang][$id]['searchable'])
                        ? (bool)$metas[$idLang][$id]['searchable']
                        : false,
                    'enabled' => isset($metas[$idLang][$id]['enabled'])
                        ? (bool)$metas[$idLang][$id]['enabled']
                        : false,
                    'aggregatable' => isset($metas[$idLang][$id]['aggregatable'])
                        ? (bool)$metas[$idLang][$id]['aggregatable']
                        : false,
                    'operator' => isset($metas[$idLang][$id]['operator'])
                        ? (int)$metas[$idLang][$id]['operator']
                        : false,
                    'display_type' => isset($metas[$idLang][$id]['display_type'])
                        ? (int)$metas[$idLang][$id]['display_type']
                        : 0,
                    'elastic_type' => isset($metas[$idLang][$id]['elastic_type'])
                        ? (string)$metas[$idLang][$id]['elastic_type']
                        : 'text',
                    'result_limit' => isset($metas[$idLang][$id]['result_limit'])
                        ? (int)$metas[$idLang][$id]['result_limit']
                        : 0,
                    'type_configurable' => isset(Fetcher::$attributes[$code]['type_configurable'])
                        ? (bool)Fetcher::$attributes[$code]['type_configurable']
                        : false,
                    'elastic_types' => isset(Fetcher::$attributes[$code]['elastic_types'])
                        ? Fetcher::$attributes[$code]['elastic_types']
                        : null,
                    'visible' => isset(Fetcher::$attributes[$code]['visible'])
                        ? (bool)Fetcher::$attributes[$code]['visible']
                        : true,
                ];
                if ($position) {
                    static::addProperty($properties, $property);
                } else {
                    $deferredProperties[] = $property;
                }
                unset($property);
            }
        } catch (PrestaShopException $e) {
            Logger::addLog("Elasticsearch module error: {$e->getMessage()}");

            return [];
        }

        $type = 'attribute';
        try {
            foreach (static::getAttributes($idLang) as $tbAttribute) {
                $id = Tools::link_rewrite($tbAttribute['attribute_group']);
                $id = "{$id}attribute";
                $position = isset($metas[$idLang][$id]['position']) ? $metas[$idLang][$id]['position'] : 0;
                $name = [];
                foreach (Language::getLanguages(true, false, true) as $language) {
                    $name[(int)$language] = isset($metas[$language][$id]['name'])
                        ? $metas[$language][$id]['name']
                        : $tbAttribute['attribute_group'];
                }
                $code = Tools::link_rewrite($tbAttribute['attribute_group']);

                $property = (object)[
                    'meta_type' => $type,
                    'code' => $code,
                    'alias' => isset($metas[$idLang][$id]['alias']) ? $metas[$idLang][$id]['alias'] : '',
                    'name' => $name,
                    'position' => $position,
                    'weight' => isset($metas[$idLang][$id]['weight'])
                        ? (float)$metas[$idLang][$id]['weight']
                        : 1,
                    'searchable' => isset($metas[$idLang][$id]['searchable'])
                        ? (bool)$metas[$idLang][$id]['searchable']
                        : false,
                    'enabled' => isset($metas[$idLang][$id]['enabled'])
                        ? (bool)$metas[$idLang][$id]['enabled']
                        : false,
                    'aggregatable' => isset($metas[$idLang][$id]['aggregatable'])
                        ? (bool)$metas[$idLang][$id]['aggregatable']
                        : false,
                    'operator' => isset($metas[$idLang][$id]['operator'])
                        ? (int)$metas[$idLang][$id]['operator']
                        : 0,
                    'display_type' => isset($metas[$idLang][$id]['display_type'])
                        ? (int)$metas[$idLang][$id]['display_type']
                        : 0,
                    'elastic_type' => isset($metas[$idLang][$id]['elastic_type'])
                        ? (string)$metas[$idLang][$id]['elastic_type']
                        : 'text',
                    'result_limit' => isset($metas[$idLang][$id]['result_limit'])
                        ? (int)$metas[$idLang][$id]['result_limit']
                        : 0,
                    'type_configurable' => isset(Fetcher::$attributes[$code]['type_configurable'])
                        ? (bool)Fetcher::$attributes[$code]['type_configurable']
                        : false,
                    'elastic_types' => isset(Fetcher::$attributes[$code]['elastic_types'])
                        ? Fetcher::$attributes[$code]['elastic_types']
                        : null,
                    'visible' => isset(Fetcher::$attributes[$code]['visible'])
                        ? Fetcher::$attributes[$code]['visible']
                        : true,
                ];
                if ($position) {
                    static::addProperty($properties, $property);
                } else {
                    $deferredProperties[] = $property;
                }
                unset($property);
            }
        } catch (PrestaShopException $e) {
            Logger::addLog("Elasticsearch module error: {$e->getMessage()}");

            return [];
        }

        usort($properties, function ($a, $b) {
            return ($a->position < $b->position) ? -1 : 1;
        });
        foreach ($deferredProperties as &$deferredAttribute) {
            static::addProperty($properties, $deferredAttribute);
        }

        return $properties;
    }

    /**
     * Get all attributes for the given Language ID
     *
     * @param int $idLang
     *
     * @return array
     */
    public static function getAttributes($idLang)
    {
        try {
            return (array)Db::getInstance(_PS_USE_SQL_SLAVE_)->executeS(
                (new DbQuery())
                    ->select('DISTINCT agl.`id_attribute_group` as `id`, agl.`name` AS `attribute_group`')
                    ->from('attribute_group', 'ag')
                    ->leftJoin(
                        'attribute_group_lang',
                        'agl',
                        'ag.`id_attribute_group` = agl.`id_attribute_group` AND agl.`id_lang` = ' . (int)$idLang
                    )
                    ->leftJoin('attribute', 'a', 'a.`id_attribute_group` = ag.`id_attribute_group`')
                    ->leftJoin(
                        'attribute_lang',
                        'al',
                        'a.`id_attribute` = al.`id_attribute` AND al.`id_lang` = ' . (int)$idLang
                    )
                    ->join(Shop::addSqlAssociation('attribute_group', 'ag'))
                    ->join(Shop::addSqlAssociation('attribute', 'a'))
                    ->orderBy('agl.`name` ASC, a.`position` ASC')
            );
        } catch (PrestaShopException $e) {
            Logger::addLog("Elasticsearch module error: {$e->getMessage()}");

            return [];
        }
    }

    /**
     * Adds a property to the props array and makes sure it says unique
     *
     * @param array $array
     * @param object $property
     */
    protected static function addProperty(&$array, $property)
    {
        $found = false;
        foreach ($array as $item) {
            if ($property->code === $item->code) {
                $found = true;
                break;
            }
        }

        if (!$found) {
            $array[] = $property;
        }
    }
}
