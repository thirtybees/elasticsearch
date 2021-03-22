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

use Db;
use DbQuery;
use Language;
use Logger;
use ObjectModel;
use PDOStatement;
use PrestaShopDatabaseException;
use PrestaShopException;
use ReflectionClass;
use ReflectionException;

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
            'meta_type' => ['type' => self::TYPE_STRING, 'validate' => 'isString', 'required' => true],
            'alias' => ['type' => self::TYPE_STRING, 'validate' => 'isString', 'required' => false],
            'code' => ['type' => self::TYPE_STRING, 'validate' => 'isString', 'required' => true],
            'enabled' => ['type' => self::TYPE_BOOL, 'validate' => 'isBool', 'required' => true],
            'elastic_type' => ['type' => self::TYPE_STRING, 'validate' => 'isString', 'required' => true],
            'searchable' => ['type' => self::TYPE_BOOL, 'validate' => 'isBool', 'required' => true],
            'weight' => ['type' => self::TYPE_INT, 'validate' => 'isUnsignedInt', 'required' => true],
            'position' => ['type' => self::TYPE_INT, 'validate' => 'isUnsignedInt', 'required' => true],
            'aggregatable' => ['type' => self::TYPE_BOOL, 'validate' => 'isBool', 'required' => true],
            'operator' => ['type' => self::TYPE_BOOL, 'validate' => 'isBool', 'required' => true],
            'display_type' => ['type' => self::TYPE_INT, 'validate' => 'isUnsignedInt', 'required' => true],
            'result_limit' => ['type' => self::TYPE_INT, 'validate' => 'isUnsignedInt', 'required' => true],

            // Multilang
            'name' => ['type' => self::TYPE_STRING, 'lang' => true, 'validate' => 'isString', 'required' => true],
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
            try {
                $idLangs = Language::getLanguages(true, null, true);
            } catch (PrestaShopException $e) {
                Logger::addLog("Elasticsearch module error: {$e->getMessage()}");

                return [];
            }
        }

        try {
            $results = (array)Db::getInstance(_PS_USE_SQL_SLAVE_)->executeS(
                (new DbQuery())
                    ->select('m.*, ml.`name`, ml.`id_lang`')
                    ->from(bqSQL(static::$definition['table']), 'm')
                    ->rightJoin(bqSQL(static::$definition['table']) . '_lang', 'ml', 'ml.`' . bqSQL(static::$definition['primary']) . '` = m.`' . bqSQL(static::$definition['primary']) . '`')
                    ->where('ml.`id_lang` IN (' . implode(',', array_map('intval', $idLangs)) . ')')
            );
        } catch (PrestaShopException $e) {
            $results = false;
        }
        $metas = [];
        foreach ($results as &$result) {
            if (!isset($metas[(int)$result['id_lang']])) {
                $metas[(int)$result['id_lang']] = [];
            }
            $metas[(int)$result['id_lang']][$result['code'] . $result['meta_type']] = $result;
        }

        return $metas;
    }

    /**
     * Save metas
     *
     * @param array $metas
     *
     * @throws PrestaShopDatabaseException
     * @throws PrestaShopException
     */
    public static function saveMetas($metas)
    {
        $processedKeys = [];
        foreach ($metas as $index => $meta) {
            if (!in_array($meta['alias'], $processedKeys)) {
                $processedKeys[] = $meta['alias'];
            } else {
                unset($metas[$index]);
            }
        }

        $metaPrimary = bqSQL(Meta::$definition['primary']);
        $metaTable = bqSQL(Meta::$definition['table']);
        $inserts = [];
        $langInserts = [];
        $position = 1;
        $fields = array_keys(static::$definition['fields']);
        foreach ($metas as $meta) {
            // Insert
            $insert = [];
            foreach ($meta as $key => $value) {
                if ($key === 'name' || !in_array($key, $fields)) {
                    continue;
                }

                $insert[$key] = $value;
            }
            $insert['position'] = $position;

            $inserts[] = $insert;
            $position++;
        }

        if (!empty($inserts)) {
            try {
                foreach ($inserts as $insert) {
                    if ($id = Db::getInstance(_PS_USE_SQL_SLAVE_)->getValue(
                        (new DbQuery())
                            ->select('`' . bqSQL(static::$definition['primary']) . '`')
                            ->from(bqSQL(static::$definition['table']))
                            ->where('`code` = \'' . pSQL($insert['code']) . '\'')
                            ->where('`meta_type` = \'' . pSQL($insert['meta_type']) . '\'')
                    )) {
                        unset($insert['position']);

                        Db::getInstance()->update(
                            $metaTable,
                            $insert,
                            '`' . bqSQL(static::$definition['primary']) . '` = ' . (int)$id
                        );
                    } else {
                        Db::getInstance()->insert($metaTable, $insert);
                    }
                }
            } catch (PrestaShopException $e) {
                Logger::addLog("Elasticsearch module error: {$e->getMessage()}");
            }
        }

        try {
            $codesAndIds = (array)Db::getInstance(_PS_USE_SQL_SLAVE_)->executeS(
                (new DbQuery())
                    ->select("m.`alias`, m.`$metaPrimary`")
                    ->from($metaTable, 'm')
            );
        } catch (PrestaShopException $e) {
            Logger::addLog("Elasticsearch module error: {$e->getMessage()}");
        }
        foreach ($metas as $meta) {
            foreach ($meta['name'] as $idLang => $name) {
                $primary = '';
                foreach ($codesAndIds as $codeAndId) {
                    if ($codeAndId['alias'] === $meta['alias']) {
                        $primary = $codeAndId[$metaPrimary];

                        break;
                    }
                }
                if (!$primary) {
                    continue;
                }


                // Insert
                $langInserts[] = [
                    $metaPrimary => $primary,
                    'id_lang' => $idLang,
                    'name' => $meta['name'][$idLang],
                ];
            }
        }
        if (!empty($langInserts)) {
            Db::getInstance()->delete("{$metaTable}_lang");
            try {
                Db::getInstance()->insert("{$metaTable}_lang", $langInserts);
            } catch (PrestaShopException $e) {
                Logger::addLog("Elasticsearch module error: {$e->getMessage()}");
            }
        }
    }

    /**
     * Get Elastic types
     *
     * @return array
     * @throws ReflectionException
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
            static::DISPLAY_TYPE_SLIDER => 'Slider',
            static::DISPLAY_TYPE_COLORS => 'Colors',
        ];
    }

    /**
     * Get the name of a meta
     *
     * @param string $alias
     * @param int $idLang
     *
     * @return false|null|string
     */
    public static function getName($alias, $idLang)
    {
        try {
            return Db::getInstance(_PS_USE_SQL_SLAVE_)->getValue(
                (new DbQuery())
                    ->select('ml.`name`')
                    ->from(bqSQL(static::$definition['table']) . '_lang', 'ml')
                    ->innerJoin(
                        bqSQL(static::$definition['table']),
                        'm',
                        'ml.`' . bqSQL(static::$definition['primary']) . '` = m.`' . bqSQL(static::$definition['primary']) . '` AND ml.`id_lang` = ' . (int)$idLang
                    )
                    ->where('m.`alias` = \'' . pSQL($alias) . '\'')
            );
        } catch (PrestaShopException $e) {
            Logger::addLog("Elasticsearch module error: {$e->getMessage()}");

            return false;
        }
    }

    /**
     * Get searchable metas (for the field section of the ES query)
     *
     * @param bool $withWeights
     *
     * @return array|false|null|PDOStatement
     */
    public static function getSearchableMetas($withWeights = true)
    {
        try {
            $metas = Db::getInstance(_PS_USE_SQL_SLAVE_)->executeS(
                (new DbQuery())
                    ->select('m.`code`, m.`alias`')
                    ->select($withWeights ? 'm.`weight`' : '')
                    ->from(bqSQL(static::$definition['table']), 'm')
                    ->where('m.`searchable` = 1')
                    // Only text type fields are truly searchable, removing the rest
                    ->where('m.`elastic_type` = \'text\'')
            );
        } catch (PrestaShopException $e) {
            Logger::addLog("Elasticsearch module error: {$e->getMessage()}");

            $metas = [];
        }

        $newMetas = [];
        $requiredMetas = ['name'];
        foreach ($metas as $meta) {
            $newMeta = $meta['alias'];
            if ($withWeights) {
                $newMeta .= '^' . $meta['weight'];
            }

            $newMetas[] = $newMeta;

            // Check if a requirement has been met, remove it from the required array if that is the case
            $pos = array_search($meta['alias'], $requiredMetas);
            if ($pos > -1) {
                unset($requiredMetas[$pos]);
            }
        }

        // Add all required fields
        foreach ($requiredMetas as $requiredMeta) {
            $newMetas[] = $requiredMeta;
        }

        return $newMetas;
    }
}
