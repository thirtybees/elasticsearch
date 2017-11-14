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

use Context;
use Language;
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
     * @param int $idLang
     *
     * @return array
     */
    public static function getSearchableAttributes($idLang)
    {
        $searchable = [];

        foreach (static::getAllAttributes() as $key => $value) {
            if ($value->checked) {
                $searchable[$key] = $value->name;
            }
        }

        return $searchable;
    }

    /**
     * Get all attributes
     *
     * @return array
     */
    public static function getAllAttributes()
    {
        $idLang = Context::getContext()->language->id;
        $attributes = [];
        $deferredAttributes = [];
        $metas = static::getAllMetas();

        $type = 'property';
        foreach (Fetcher::$attributes as $defaultAttributeName => $defaultAttribute) {
            $id = $defaultAttributeName;
            $position = isset($metas[$idLang][$id]) && isset($metas[$idLang][$id]['position']) ? $metas[$idLang][$id]['position'] : 0;
            $name = [];
            foreach (Language::getLanguages(false, false, true) as $language) {
                $name[(int) $language] = isset($metas[$language][$id]['name']) ? $metas[$language][$id]['name'] : $defaultAttributeName;
            }
            $elasticType = isset($metas[$idLang][$id]) && isset($metas[$idLang][$id]['elastic_type']) ? $metas[$idLang][$id]['elastic_type'] : 'text';
            if (isset($defaultAttribute['elastic_types']) && !in_array($elasticType, $defaultAttribute['elastic_types'])) {
                $elasticType = isset($defaultAttribute['default']) ? $defaultAttribute['default'] : $defaultAttribute['elastic_types'][0];
            }

            $attribute = (object) [
                'meta_type'         => $type,
                'code'              => $defaultAttributeName,
                'name'              => $name,
                'position'          => $position,
                'weight'            => (float) (isset($metas[$idLang][$id]) && isset($metas[$idLang][$id]['weight']) ? $metas[$idLang][$id]['weight'] : 1),
                'searchable'        => (int) (isset($metas[$idLang][$id]) && isset($metas[$idLang][$id]['searchable']) ? $metas[$idLang][$id]['searchable'] : false),
                'enabled'           => (int) (isset($metas[$idLang][$id]) && isset($metas[$idLang][$id]['enabled']) ? $metas[$idLang][$id]['enabled'] : false),
                'aggregatable'      => (int) (isset($metas[$idLang][$id]) && isset($metas[$idLang][$id]['aggregatable']) ? $metas[$idLang][$id]['aggregatable'] : false),
                'operator'          => (int) isset($metas[$idLang][$id]) && isset($metas[$idLang][$id]['operator']) ? $metas[$idLang][$id]['operator'] : false,
                'display_type'      => (int) isset($metas[$idLang][$id]) && isset($metas[$idLang][$id]['display_type']) ? $metas[$idLang][$id]['display_type'] : 0,
                'elastic_type'      => $elasticType,
                'result_limit'      => (int) isset($metas[$idLang][$id]) && isset($metas[$idLang][$id]['result_limit']) ? $metas[$idLang][$id]['result_limit'] : 0,
                'type_configurable' => isset(Fetcher::$attributes[$defaultAttributeName]['type_configurable']) ? Fetcher::$attributes[$defaultAttributeName]['type_configurable'] : false,
                'elastic_types'     => isset(Fetcher::$attributes[$defaultAttributeName]['elastic_types']) ? Fetcher::$attributes[$defaultAttributeName]['elastic_types'] : null,
                'visible'           => isset(Fetcher::$attributes[$defaultAttributeName]['visible']) ? Fetcher::$attributes[$defaultAttributeName]['visible'] : true,
            ];
            if ($position) {
                $attributes[] = $attribute;
            } else {
                $deferredAttributes[] = $attribute;
            }
            unset($attribute);
        }

        $type = 'feature';
        foreach (\Feature::getFeatures($idLang) as $feature) {
            $id = Tools::link_rewrite($feature['name']);
            $position = isset($metas[$idLang][$id]) && isset($metas[$idLang][$id]['position']) ? $metas[$idLang][$id]['position'] : 0;
            $name = [];
            foreach (Language::getLanguages(false, false, true) as $language) {
                $name[(int) $language] = isset($metas[$language][$id]['name']) ? $metas[$language][$id]['name'] : $feature['name'];
            }
            $code = Tools::link_rewrite($feature['name']);

            $attribute = (object) [
                'meta_type'    => $type,
                'code'         => $code,
                'name'         => $name,
                'position'     => $position,
                'weight'       => (float) (isset($metas[$idLang][$id]) && isset($metas[$idLang][$id]['weight']) ? $metas[$idLang][$id]['weight'] : 1),
                'searchable'   => (int) (isset($metas[$idLang][$id]) && isset($metas[$idLang][$id]['searchable']) ? $metas[$idLang][$id]['searchable'] : false),
                'enabled'      => (int) (isset($metas[$idLang][$id]) && isset($metas[$idLang][$id]['enabled']) ? $metas[$idLang][$id]['enabled'] : false),
                'aggregatable' => (int) (isset($metas[$idLang][$id]) && isset($metas[$idLang][$id]['aggregatable']) ? $metas[$idLang][$id]['aggregatable'] : false),
                'operator'     => (int) isset($metas[$idLang][$id]) && isset($metas[$idLang][$id]['operator']) ? $metas[$idLang][$id]['operator'] : false,
                'display_type' => (int) isset($metas[$idLang][$id]) && isset($metas[$idLang][$id]['display_type']) ? $metas[$idLang][$id]['display_type'] : 0,
                'elastic_type' => isset($metas[$idLang][$id]) && isset($metas[$idLang][$id]['elastic_type']) ? $metas[$idLang][$id]['elastic_type'] : 'text',
                'result_limit' => (int) isset($metas[$idLang][$id]) && isset($metas[$idLang][$id]['result_limit']) ? $metas[$idLang][$id]['result_limit'] : 0,
                'type_configurable' => isset(Fetcher::$attributes[$code]['type_configurable']) ? Fetcher::$attributes[$code]['type_configurable'] : false,
                'elastic_types'     => isset(Fetcher::$attributes[$code]['elastic_types']) ? Fetcher::$attributes[$code]['elastic_types'] : null,
                'visible'           => isset(Fetcher::$attributes[$code]['visible']) ? Fetcher::$attributes[$code]['visible'] : true,
            ];
            if ($position) {
                $attributes[] = $attribute;
            } else {
                $deferredAttributes[] = $attribute;
            }
            unset($attribute);
        }

        $type = 'attribute';
        foreach (static::getAttributes($idLang) as $tbAttribute) {
            $id = Tools::link_rewrite($tbAttribute['attribute_group']);
            $position = isset($metas[$idLang][$id]) && isset($metas[$idLang][$id]['position']) ? $metas[$idLang][$id]['position'] : 0;
            $name = [];
            foreach (Language::getLanguages(false, false, true) as $language) {
                $name[(int) $language] = isset($metas[$language][$id]['name']) ? $metas[$language][$id]['name'] : $tbAttribute['attribute_group'];
            }
            $code = Tools::link_rewrite($tbAttribute['attribute_group']);

            $attribute = (object) [
                'meta_type'         => $type,
                'code'              => $code,
                'name'              => $name,
                'position'          => $position,
                'weight'            => (float) (isset($metas[$idLang][$id]) && isset($metas[$idLang][$id]['weight']) ? $metas[$idLang][$id]['weight'] : 1),
                'searchable'        => (int) (isset($metas[$idLang][$id]) && isset($metas[$idLang][$id]['searchable']) ? $metas[$idLang][$id]['searchable'] : false),
                'enabled'           => (int) (isset($metas[$idLang][$id]) && isset($metas[$idLang][$id]['enabled']) ? $metas[$idLang][$id]['enabled'] : false),
                'aggregatable'      => (int) (isset($metas[$idLang][$id]) && isset($metas[$idLang][$id]['aggregatable']) ? $metas[$idLang][$id]['aggregatable'] : false),
                'operator'          => (int) isset($metas[$idLang][$id]) && isset($metas[$idLang][$id]['operator']) ? $metas[$idLang][$id]['operator'] : false,
                'display_type'      => (int) isset($metas[$idLang][$id]) && isset($metas[$idLang][$id]['display_type']) ? $metas[$idLang][$id]['display_type'] : 0,
                'elastic_type'      => isset($metas[$idLang][$id]) && isset($metas[$idLang][$id]['elastic_type']) ? $metas[$idLang][$id]['elastic_type'] : 'text',
                'result_limit'      => (int) isset($metas[$idLang][$id]) && isset($metas[$idLang][$id]['result_limit']) ? $metas[$idLang][$id]['result_limit'] : 0,
                'type_configurable' => isset(Fetcher::$attributes[$code]['type_configurable']) ? Fetcher::$attributes[$code]['type_configurable'] : false,
                'elastic_types'     => isset(Fetcher::$attributes[$code]['elastic_types']) ? Fetcher::$attributes[$code]['elastic_types'] : null,
                'visible'           => isset(Fetcher::$attributes[$code]['visible']) ? Fetcher::$attributes[$code]['visible'] : true,
            ];
            if ($position) {
                $attributes[] = $attribute;
            } else {
                $deferredAttributes[] = $attribute;
            }
            unset($attribute);
        }

        usort($attributes, function ($a, $b) {
            return ($a->position < $b->position) ? -1 : 1;
        });
        foreach ($deferredAttributes as &$deferredAttribute) {
            $attributes[] = $deferredAttribute;
        }

        return $attributes;
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
        return (array) \Db::getInstance(_PS_USE_SQL_SLAVE_)->executeS(
            (new \DbQuery())
                ->select('DISTINCT agl.`id_attribute_group` as `id`, agl.`name` AS `attribute_group`')
                ->from('attribute_group', 'ag')
                ->leftJoin('attribute_group_lang', 'agl', 'ag.`id_attribute_group` = agl.`id_attribute_group` AND agl.`id_lang` = '.(int) $idLang)
                ->leftJoin('attribute', 'a', 'a.`id_attribute_group` = ag.`id_attribute_group`')
                ->leftJoin('attribute_lang', 'al', 'a.`id_attribute` = al.`id_attribute` AND al.`id_lang` = '.(int) $idLang)
                ->join(Shop::addSqlAssociation('attribute_group', 'ag'))
                ->join(Shop::addSqlAssociation('attribute', 'a'))
                ->orderBy('agl.`name` ASC, a.`position` ASC')
        );
    }
}
