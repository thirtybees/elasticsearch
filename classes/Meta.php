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
use Db;
use DbQuery;
use Language;
use ObjectModel;
use ReflectionClass;

if (!defined('_TB_VERSION_')) {
    exit;
}

/**
 * Class SearchMeta
 *
 * @package ElasticsearchModule
 */
class Meta extends ObjectModel
{
    use MetaAttributesTrait;

    const ELASTIC_TYPE_TEXT = 'text';
    const ELASTIC_TYPE_KEYWORD = 'keyword';
    const ELASTIC_TYPE_LONG = 'long';
    const ELASTIC_TYPE_INTEGER = 'integer';
    const ELASTIC_TYPE_SHORT = 'short';
    const ELASTIC_TYPE_BYTE = 'byte';
    const ELASTIC_TYPE_DOUBLE = 'double';
    const ELASTIC_TYPE_FLOAT = 'float';
    const ELASTIC_TYPE_HALF_FLOAT = 'half_float';
    const ELASTIC_TYPE_SCALED_FLOAT = 'scaled_float';
    const ELASTIC_TYPE_DATE = 'date';
    const ELASTIC_TYPE_BOOLEAN = 'boolean';
    const ELASTIC_TYPE_BINARY = 'binary';
    const ELASTIC_TYPE_NESTED = 'nested';

    const DISPLAY_TYPE_CHECKBOX = 1;
    const DISPLAY_TYPE_RADIO = 2;
    const DISPLAY_TYPE_LIST = 3;
    const DISPLAY_TYPE_SLIDER = 4;
    const DISPLAY_TYPE_COLORS = 5;

    const CONJUNCTIVE = 0;
    const DISJUNCTIVE = 1;

    /**
     * @var array
     */
    public static $definition = [
        'primary' => 'id_elasticsearch_meta',
        'table' => 'elasticsearch_meta',
        'fields' => [
            'meta_type'    => ['type' => self::TYPE_STRING,                 'validate' => 'isString',      'required' => true],
            'code'         => ['type' => self::TYPE_STRING,                 'validate' => 'isString',      'required' => true],
            'elastic_type' => ['type' => self::TYPE_STRING,                 'validate' => 'isString',      'required' => true],
            'searchable'   => ['type' => self::TYPE_BOOL,                   'validate' => 'isBool',        'required' => true],
            'weight'       => ['type' => self::TYPE_INT,                    'validate' => 'isUnsignedInt', 'required' => true],
            'position'     => ['type' => self::TYPE_INT,                    'validate' => 'isUnsignedInt', 'required' => true],
            'aggregatable' => ['type' => self::TYPE_BOOL,                   'validate' => 'isBool',        'required' => true],
            'operator'     => ['type' => self::TYPE_BOOL,                   'validate' => 'isBool',        'required' => true],
            'display_type' => ['type' => self::TYPE_INT,                    'validate' => 'isUnsignedInt', 'required' => true],
            'result_limit' => ['type' => self::TYPE_INT,                    'validate' => 'isUnsignedInt', 'required' => true],

            // Multilang
            'name'         => ['type' => self::TYPE_STRING, 'lang' => true, 'validate' => 'isString',      'required' => true],
        ],
    ];

    /**
     * Get all metas at once
     *
     * @param int[]|null $idLangs
     *
     * @return array
     */
    public static function getAllMetas($idLangs = null)
    {
        if (!is_array($idLangs) || !empty($idLangs)) {
            $idLangs = Language::getLanguages(false, null, true);
        }

        $results = (array) Db::getInstance(_PS_USE_SQL_SLAVE_)->executeS(
            (new DbQuery())
                ->select('m.*, ml.`name`, ml.`id_lang`')
                ->from(bqSQL(static::$definition['table']), 'm')
                ->rightJoin(bqSQL(static::$definition['table']).'_lang', 'ml', 'ml.`'.bqSQL(static::$definition['primary']).'` = m.`'.bqSQL(static::$definition['primary']).'`')
                ->where('ml.`id_lang` IN ('.implode(',', array_map('intval', $idLangs)).')')
        );
        $metas = [];
        foreach ($results as &$result) {
            if (!isset($metas[(int) $result['id_lang']])) {
                $metas[(int) $result['id_lang']] = [];
            }
            $metas[(int) $result['id_lang']][$result['code']] = $result;
        }

        return $metas;
    }

    /**
     * Save metas
     *
     * @param array $metas
     */
    public static function saveMetas($metas)
    {
        $existingMetas = static::getAllMetas();
        $metaPrimary = bqSQL(Meta::$definition['primary']);
        $metaTable = bqSQL(Meta::$definition['table']);
        $idLang = Context::getContext()->language->id;

        $inserts = [];
        $langInserts = [];
        $position = 1;
        foreach ($metas as $meta) {
            if (isset($existingMetas[$idLang][$meta['code']])) {
                // Update
                $update = [];
                foreach ($meta as $key => $value) {
                    if ($key === 'name') {
                        continue;
                    }

                    $update[$key] = $value;
                }

                $update[$metaPrimary] = $existingMetas[$idLang][$meta['code']][$metaPrimary];
                $update['position'] = $position;
                Db::getInstance()->update(
                    $metaTable,
                    $update,
                    "`$metaPrimary` = {$existingMetas[$idLang][$meta['code']][$metaPrimary]}"
                );

            } else {
                // Insert
                $insert = [];
                foreach ($meta as $key => $value) {
                    if ($key === 'name') {
                        continue;
                    }

                    $insert[$key] = $value;
                }
                $insert['position'] = $position;

                $inserts[] = $insert;
            }

            $position++;
        }

        if (!empty($inserts)) {
            Db::getInstance()->insert($metaTable, $inserts);
        }

        $codesAndIds = (array) Db::getInstance(_PS_USE_SQL_SLAVE_)->executeS(
            (new DbQuery())
                ->select("m.`code`, m.`$metaPrimary`")
                ->from($metaTable, 'm')
        );
        foreach ($metas as $meta) {
            foreach ($meta['name'] as $idLang => $name) {
                $primary = '';
                foreach ($codesAndIds as $codeAndId) {
                    if ($codeAndId['code'] === $meta['code']) {
                        $primary = $codeAndId[$metaPrimary];

                        break;
                    }
                }
                if (!$primary) {
                    continue;
                }

                if (isset($existingMetas[$idLang][$meta['code']])) {
                    // Update
                    Db::getInstance()->update("{$metaTable}_lang", [
                        $metaPrimary => $primary,
                        'id_lang'    => $idLang,
                        'name'       => $meta['name'][$idLang],
                    ], "`$metaPrimary` = $primary AND `id_lang` = $idLang");
                } else {
                    // Insert
                    $langInserts[] = [
                        $metaPrimary => $primary,
                        'id_lang'    => $idLang,
                        'name'       => $meta['name'][$idLang],
                    ];
                }
            }
        }
        if (!empty($langInserts)) {
            Db::getInstance()->insert("{$metaTable}_lang", $langInserts);
        }
    }

    /**
     * Get Elastic types
     *
     * @return array
     */
    public static function getElasticTypes()
    {
        return array_filter((new ReflectionClass(get_called_class()))->getConstants(), function ($const) {
            return substr($const, 0, 13) === 'ELASTIC_TYPE_';
        }, ARRAY_FILTER_USE_KEY);
    }

    /**
     * Get display types
     *
     * @return array
     */
    public static function getDisplayTypes()
    {
        // At the moment only checkboxes are supported
        return [
            static::DISPLAY_TYPE_CHECKBOX => 'Checkbox',
//            static::DISPLAY_TYPE_RADIO    => 'Radio buttons',
//            static::DISPLAY_TYPE_LIST     => 'Dropdown',
            static::DISPLAY_TYPE_SLIDER   => 'Slider',
            static::DISPLAY_TYPE_COLORS   => 'Colors',
        ];
    }
}
