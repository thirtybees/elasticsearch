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

use Category;
use Group;
use Context;
use Customer;
use Db;
use DbQuery;
use Image;
use ImageType;
use Link;
use Manufacturer;
use Page;
use Product;
use ProductSale;
use Shop;
use stdClass;
use Tools;

if (!defined('_TB_VERSION_')) {
    return;
}

/**
 * Class Fetcher
 *
 * When fetching a product for Elasticsearch indexing, it will call the functions as defined in the
 * `$attributes` array. If the value `null` is used, it will grab the property directly from the
 * thirty bees Product object.
 *
 * @package ElasticsearchModule
 */
class Fetcher
{
    /**
     * Properties array
     *
     * Defaults:
     * - function: null
     * - default: 'text'
     * - elastic_types: all
     * - visible: true
     *
     * @var array $attributes
     */
    public static $attributes = [
        'name'                    => [
            'function'      => null,
            'default'       => Meta::ELASTIC_TYPE_TEXT,
            'elastic_types' => [
                Meta::ELASTIC_TYPE_KEYWORD,
                Meta::ELASTIC_TYPE_TEXT,
            ],
        ],
        'reference'               => [
            'function'      => [__CLASS__, 'getTrimmedRef'],
            'default'       => Meta::ELASTIC_TYPE_TEXT,
            'elastic_types' => [
                META::ELASTIC_TYPE_KEYWORD,
                META::ELASTIC_TYPE_TEXT,
            ],
        ],
        'on_sale'                 => [
            'function' => [__CLASS__, 'getOnSale'],
            'default'  => Meta::ELASTIC_TYPE_BINARY,
        ],
        'available_now'           => [
            'function' => [__CLASS__, 'getAvailableNow'],
            'default'  => Meta::ELASTIC_TYPE_BINARY,
            'elastic_types' => [
                Meta::ELASTIC_TYPE_BINARY,
            ],
        ],
        'category'                => [
            'function'      => [__CLASS__, 'getCategoryName'],
            'default'       => Meta::ELASTIC_TYPE_TEXT,
            'elastic_types' => [
                Meta::ELASTIC_TYPE_KEYWORD,
                Meta::ELASTIC_TYPE_TEXT,
            ],
        ],
        'categories'              => [
            'function'      => [__CLASS__, 'getCategoriesNames'],
            'default'       => Meta::ELASTIC_TYPE_TEXT,
            'elastic_types' => [
                Meta::ELASTIC_TYPE_KEYWORD,
                Meta::ELASTIC_TYPE_TEXT,
            ],
        ],
        'manufacturer'            => [
            'function'      => [__CLASS__, 'getManufacturerName'],
            'default'       => Meta::ELASTIC_TYPE_TEXT,
            'elastic_types' => [
                Meta::ELASTIC_TYPE_KEYWORD,
                Meta::ELASTIC_TYPE_TEXT,
            ],
        ],
        'categories_without_path' => [
            'function'      => [__CLASS__, 'getCategoriesNamesWithoutPath'],
            'default'       => Meta::ELASTIC_TYPE_TEXT,
            'elastic_types' => [
                Meta::ELASTIC_TYPE_KEYWORD,
                Meta::ELASTIC_TYPE_TEXT,
            ],
        ],
        'date_add'                => [
            'function'     => null,
            'default'      => Meta::ELASTIC_TYPE_DATE,
            'elastic_types' => [
                Meta::ELASTIC_TYPE_DATE,
            ],
        ],
        'date_upd'                => [
            'function'     => null,
            'default'      => Meta::ELASTIC_TYPE_DATE,
            'elastic_types' => [
                Meta::ELASTIC_TYPE_DATE,
            ],
        ],
        'description'             => [
            'function'      => null,
            'default'       => Meta::ELASTIC_TYPE_TEXT,
            'elastic_types' => [
                Meta::ELASTIC_TYPE_KEYWORD,
                Meta::ELASTIC_TYPE_TEXT,
            ],
        ],
        'description_short'       => [
            'function'      => null,
            'default'       => Meta::ELASTIC_TYPE_TEXT,
            'elastic_types' => [
                Meta::ELASTIC_TYPE_KEYWORD,
                Meta::ELASTIC_TYPE_TEXT,
            ],
        ],
        'ean13'                   => [
            'function'      => [__CLASS__, 'getEan'],
            'default'       => Meta::ELASTIC_TYPE_TEXT,
            'elastic_types' => [
                Meta::ELASTIC_TYPE_KEYWORD,
                Meta::ELASTIC_TYPE_TEXT,
            ],
        ],
        'image_link_large'        => [
            'function' => [__CLASS__, 'generateImageLinkLarge'],
            'default'  => Meta::ELASTIC_TYPE_KEYWORD,
            'visible'  => false,
            'elastic_types' => [
                Meta::ELASTIC_TYPE_KEYWORD,
            ],
        ],
        'image_link_small'        => [
            'function' => [__CLASS__, 'generateImageLinkSmall'],
            'default'  => Meta::ELASTIC_TYPE_KEYWORD,
            'visible'  => false,
            'elastic_types' => [
                Meta::ELASTIC_TYPE_KEYWORD,
            ],
        ],
        'link'                    => [
            'function' => [__CLASS__, 'generateLinkRewrite'],
            'default'  => Meta::ELASTIC_TYPE_KEYWORD,
            'visible'  => false,
            'elastic_types' => [
                Meta::ELASTIC_TYPE_KEYWORD,
            ],
        ],
        'id_tax_rules_group'      => [
            'function' => null,
            'default'  => Meta::ELASTIC_TYPE_NESTED,
            'visible'  => false,
            'elastic_types' => [
                Meta::ELASTIC_TYPE_NESTED,
            ],
        ],
        'price_tax_excl'          => [
            'function' => [__CLASS__, 'getPriceTaxExcl'],
            'default'  => Meta::ELASTIC_TYPE_FLOAT,
            'elastic_types' => [
                Meta::ELASTIC_TYPE_FLOAT,
            ],
        ],
        'supplier'                => [
            'function'      => [__CLASS__, 'getSupplierName'],
            'default'       => Meta::ELASTIC_TYPE_TEXT,
            'elastic_types' => [
                Meta::ELASTIC_TYPE_KEYWORD,
                Meta::ELASTIC_TYPE_TEXT,
            ],
        ],
        'ordered_qty'             => [
            'function' => [__CLASS__, 'getOrderedQty'],
            'default'  => Meta::ELASTIC_TYPE_INTEGER,
            'visible'  => false,
            'elastic_types' => [
                Meta::ELASTIC_TYPE_INTEGER,
            ],
        ],
        'stock_qty'               => [
            'function' => [__CLASS__, 'getStockQty'],
            'default'  => Meta::ELASTIC_TYPE_INTEGER,
            'visible'  => false,
            'elastic_types' => [
                Meta::ELASTIC_TYPE_INTEGER,
            ],
        ],
        'condition'               => [
            'function' => null,
            'default'  => Meta::ELASTIC_TYPE_KEYWORD,
            'visible'  => false,
            'elastic_types' => [
                Meta::ELASTIC_TYPE_KEYWORD,
            ],
        ],
        'weight'                  => [
            'function' => null,
            'default'  => Meta::ELASTIC_TYPE_FLOAT,
            'visible'  => false,
            'elastic_types' => [
                Meta::ELASTIC_TYPE_FLOAT,
            ],
        ],
        'pageviews'               => [
            'function' => [__CLASS__, 'getPageViews'],
            'default'  => Meta::ELASTIC_TYPE_INTEGER,
            'elastic_types' => [
                Meta::ELASTIC_TYPE_INTEGER,
            ],
        ],
        'sales'                   => [
            'function' => [__CLASS__, 'getSales'],
            'default'  => Meta::ELASTIC_TYPE_INTEGER,
            'elastic_types' => [
                Meta::ELASTIC_TYPE_INTEGER,
            ],
        ],
    ];

    /**
     * This function automatically calls all the attribute function in this
     * class and returns a "fetched" product with the defined attributes
     *
     * @param int $idProduct
     * @param int $idLang
     *
     * @return stdClass
     */
    public static function initProduct($idProduct, $idLang)
    {
        $elasticProduct = new stdClass();
        $elasticProduct->id = (int) $idProduct;
        $product = new Product($idProduct, true, $idLang);

        // Default properties
        foreach (static::$attributes as $propName => $propItems) {
            if ($propItems['function'] != null && method_exists($propItems['function'][0], $propItems['function'][1])) {
                $elasticProduct->$propName = call_user_func($propItems['function'], $product, $idLang);

                continue;
            }

            if (isset(Product::$definition[$propName]['lang']) == true) {
                $elasticProduct->$propName = $product->{$propName}[$idLang];
            } else {
                $elasticProduct->$propName = $product->{$propName};
            }
        }

        // Features
        foreach ($product->getFrontFeatures($idLang) as $feature) {
            $name = Tools::link_rewrite($feature['name']);
            $propItems = $feature['value'];

            $elasticProduct->$name = $propItems;
        }

        // Attribute groups
        foreach ($product->getAttributesGroups($idLang) as $attribute) {
            $groupName = Tools::link_rewrite($attribute['group_name']);
            $attributeName = $attribute['attribute_name'];

            if (!isset($elasticProduct->{$groupName}) || !is_array($elasticProduct->{$groupName})) {
                $elasticProduct->{$groupName} = [];
            }

            if (!in_array($attributeName, $elasticProduct->{$groupName})) {
                $elasticProduct->{$groupName}[] = $attributeName;
            }

            if ($attribute['is_color_group']) {
                // Add a special property for the color group
                // We assume [ yes, we are assuming something, I know :) ] that the color names and color codes
                // will eventually be in the same order, so that's how you can match them later
                if (!isset($elasticProduct->{"{$groupName}_color_code"}) || !is_array($elasticProduct->{"{$groupName}_color_code"})) {
                    $elasticProduct->{"{$groupName}_color_code"} = [];
                }

                if (!in_array($attribute['attribute_color'], $elasticProduct->{"{$groupName}_color_code"})) {
                    $elasticProduct->{"{$groupName}_color_code"}[] = $attribute['attribute_color'];
                }
            }
        }

        // Casting
        foreach ($elasticProduct as $propName => &$value) {
            $value = call_user_func([get_called_class(), 'tryCast'], $value);
        }

        // Remove blacklisted fields
        foreach (explode(',', \Configuration::get(\Elasticsearch::BLACKLISTED_FIELDS)) as $blacklistedField) {
            if (isset($elasticProduct->$blacklistedField)) {
                unset($elasticProduct->$blacklistedField);
            }
        }

        return $elasticProduct;
    }

    /**
     * Collect the amount of page views for a product
     *
     * @param Product $product
     *
     * @return false|null|string
     */
    public static function getPageViews($product)
    {
        return Db::getInstance(_PS_USE_SQL_SLAVE_)->getValue(
            (new DbQuery())
                ->select('IFNULL(SUM(pv.`counter`), 0)')
                ->from('page', 'pa')
                ->leftJoin('page_viewed', 'pv', 'pa.`id_page` = pv.`id_page`')
                ->where('pa.`id_object` = '.(int) $product->id)
                ->where('pa.`id_page_type` = '.(int) Page::getPageTypeByName('product'))
        );

    }

    /**
     * Get amount of sales for this product
     *
     * @param Product $product
     *
     * @return int
     */
    public static function getSales($product)
    {
        $sales = ProductSale::getNbrSales($product->id);

        return $sales > 0 ? $sales : 0;
    }

    /**
     * Try to cast to either a float or int
     *
     * @param mixed $value
     *
     * @return float|int
     */
    protected static function tryCast($value)
    {
        if (is_numeric($value) && floatval($value) == floatval(intval($value))) {
            return (int) $value;
        }

        if (is_numeric($value)) {
            return (float) $value;
        }

        return $value;
    }

    /**
     * Get stock quantity
     */
    protected static function getStockQty($product)
    {
        return Product::getQuantity($product->id);
    }

    /**
     * Get the ordered quantity
     *
     * @param Product $product
     *
     * @return int
     */
    protected static function getOrderedQty($product)
    {
        if (!$product instanceof Product) {
            return 0;
        }

        return (int) Db::getInstance(_PS_USE_SQL_SLAVE_)->getValue(
            (new DbQuery())
                ->select('SUM(`product_quantity`) AS `total`')
                ->from('order_detail')
                ->where('`product_id` = '.(int) $product->id)
        );
    }

    /**
     * Get price tax excl for all customer groups (pre-calc group discounts)
     *
     * @param Product $product
     *
     * @return array
     *
     * @todo: optimize `getGroups` query and include default Customer IDs for higher performance
     */
    protected static function getPriceTaxExcl($product)
    {
        // Simulate customer group prices via Customers in those groups
        // Base price (0) is grabbed directly from the database
        // Visitor group (1) is used as the default group for tax excl. prices
        $prices = [
            'group_0' => (float) static::getProductBasePrice($product->id),
            'group_1' => (float) Product::getPriceStatic($product->id, false, null, _TB_PRICE_DATABASE_PRECISION_),
        ];
        foreach (Group::getGroups(Context::getContext()->language->id) as $group) {
            if ((int) $group['id_group'] === 1) {
                continue;
            }
            // Get a default customer in this group, if not available, skip. You will have to reindex this product
            // once you add a customer to this (new) group
            $idCustomer = Db::getInstance(_PS_USE_SQL_SLAVE_)->getValue(
                (new DbQuery())
                    ->select('c.`id_customer`')
                    ->from(bqSQL(Customer::$definition['table']), 'c')
                    ->innerJoin('customer_group', 'cg', 'cg.`id_customer` = c.`id_customer`')
                    ->where('cg.`id_group` = '.(int) $group['id_group'])
            );
            if (!$idCustomer) {
                $prices["group_{$group['id_group']}"] = $prices['group_0'];

                continue;
            }
            $prices["group_{$group['id_group']}"] = (float) Product::getPriceStatic(
                $product->id,
                false,
                null,
                _TB_PRICE_DATABASE_PRECISION_,
                null,
                false,
                true,
                1,
                false,
                $idCustomer
            );
        }

        return $prices;
    }

    /**
     * Generate large image link
     *
     * @param Product $product
     * @param int     $idLang
     *
     * @return string
     */
    protected static function generateImageLinkLarge($product, $idLang)
    {
        $link = new Link();
        $cover = Image::getCover($product->id);

        if ($cover['id_image']) {
            $imageLink = $link->getImageLink($product->link_rewrite[$idLang], $cover["id_image"], ImageType::getFormatedName("search"));
        } else {
            $imageLink = Tools::getHttpHost()._THEME_PROD_DIR_.'en-default-search_default.jpg';
        }

        return $imageLink;
    }

    /**
     * Generate small image link
     *
     * @param Product $product
     * @param int     $idLang
     *
     * @return string
     */
    protected static function generateImageLinkSmall($product, $idLang)
    {
        $link = new Link();
        $cover = Image::getCover($product->id);

        if ($cover['id_image']) {
            $imageLink = $link->getImageLink($product->link_rewrite[$idLang], $cover["id_image"], ImageType::getFormatedName("small"));
        } else {
            $imageLink = Tools::getHttpHost()._THEME_PROD_DIR_.'en-default-small_default.jpg';
        }

        return $imageLink;
    }

    /**
     * Generate url slug
     *
     * @param Product $product
     * @param int     $idLang
     *
     * @return string
     */
    protected static function generateLinkRewrite($product, $idLang)
    {
        return Context::getContext()->link->getProductLink(
            $product->id,
            null,
            null,
            null,
            $idLang,
            Context::getContext()->shop->id,
            0,
            true
        );
    }

    protected static function getCategoryName($product, $idLang)
    {
        $category = new Category($product->id_category_default, $idLang);

        return $category->name;
    }

    /**
     * Get category names without path
     *
     * @param Product $product
     * @param int     $idLang
     *
     * @return array
     */
    protected static function getCategoriesNamesWithoutPath($product, $idLang)
    {
        $categories = static::getNestedCategoriesData($idLang, $product);

        $results = [];
        static::getNestedCatsWithoutPath($categories, $results, $idLang);

        return $results;
    }

    /**
     * Get nested categories data
     *
     * @param int     $idLang
     * @param Product $product
     *
     * @return array
     */
    protected static function getNestedCategoriesData($idLang, $product)
    {
        $cats = Db::getInstance(_PS_USE_SQL_SLAVE_)->executeS(
            (new DbQuery())
                ->select('c.*, cl.*')
                ->from('category', 'c')
                ->join(Shop::addSqlAssociation('category', 'c'))
                ->leftJoin('category_lang', 'cl', 'c.`id_category` = cl.`id_category`'.Shop::addSqlRestrictionOnLang('cl'))
                ->leftJoin('category_product', 'cp', 'cp.`id_category` = c.`id_category` AND cp.`id_product` = '.(int) $product->id)
                ->where('`id_lang` = '.(int) $idLang)
                ->where('c.`active` = 1')
                ->orderBy('c.`level_depth` ASC, category_shop.`position` ASC')
        );

        $categories = [];
        $buff = [];

        if (!isset($rootCategory)) {
            $rootCategory = Category::getRootCategory()->id;
        }

        foreach ($cats as $row) {
            foreach (static::getCategoryPath($row['id_category'], $idLang) as $other) {
                $cats[] = $other;
            }
        }

        $cats = array_intersect_key($cats, array_unique(array_map('serialize', $cats)));

        usort($cats, function ($a, $b) {
            if ($a['level_depth'] < $b['level_depth']) {
                return -1;
            }
            if ($a['level_depth'] > $b['level_depth']) {
                return 1;
            }

            return 0;
        });

        foreach ($cats as $row) {
            $current = &$buff[$row['id_category']];
            $current = $row;

            if ($row['id_category'] == $rootCategory) {
                $categories[$row['id_category']] = &$current;
            } else {
                $buff[$row['id_parent']]['children'][$row['id_category']] = &$current;
            }
        }

        return $categories;
    }

    /**
     * Get category path
     *
     * @param int $idCategory
     * @param int $idLang
     *
     * @return array
     */
    protected static function getCategoryPath($idCategory, $idLang)
    {
        $cats = [];
        $interval = Category::getInterval($idCategory);

        if ($interval) {
            $categories = Db::getInstance(_PS_USE_SQL_SLAVE_)->executeS(
                (new DbQuery())
                    ->select('c.*, cl.*')
                    ->from('category', 'c')
                    ->leftJoin('category_lang', 'cl', 'c.`id_category` = cl.`id_category`')
                    ->join(Shop::addSqlRestrictionOnLang('cl'))
                    ->join(Shop::addSqlAssociation('category', 'c'))
                    ->where('c.`nleft` <= '.(int) $interval['nleft'])
                    ->where('c.`nright` >= '.(int) $interval['nright'])
                    ->where('cl.`id_lang` = '.(int) $idLang)
                    ->where('c.`active` = 1')
                    ->orderBy('c.`level_depth` ASC')
            );

            foreach ($categories as $category) {
                $cats[] = $category;
            }
        }

        return $cats;
    }

    /**
     * Get nested categories without paths
     *
     * @param array $cats
     * @param array $results
     * @param int   $idLang
     */
    protected static function getNestedCatsWithoutPath($cats, &$results, $idLang)
    {
        foreach ($cats as $cat) {
            if (isset($cat['children']) && is_array($cat['children']) && count($cat['children']) > 0) {
                static::getNestedCatsWithoutPath($cat['children'], $results, $idLang);
            } else {
                if ($cat['is_root_category'] == 0) {
                    $results[] = $cat['name'];
                }
            }
        }
    }

    /**
     * Get category names
     *
     * @param Product $product
     * @param int     $idLang
     *
     * @return array
     */
    protected static function getCategoriesNames($product, $idLang)
    {
        $categories = static::getNestedCategoriesData($idLang, $product);

        $results = [];

        static::getNestedCats(0, $categories[2], '', $results);

        $finalResults = [];

        foreach ($results as $key => $value) {
            $finalResults["$key"] = $value;
        }

        return $finalResults;
    }

    /**
     * @param $key
     * @param $value
     * @param $prefix
     * @param $solution
     *
     * @return string
     */
    protected static function getNestedCats($key, $value, $prefix, &$solution)
    {
        if (is_string($key) && $key == "name") {
            if ($value == 'Home') {
                return '';
            }

            if (empty($prefix)) {
                $prefix .= "$value";
            } else {
                $prefix .= " /// $value";
            }

            array_push($solution, $prefix);

            return $prefix;
        } else { // $key is numeric or children and value is an array
            $p = $prefix;
            if (is_numeric($key) || $key == 'children') {
                foreach ($value as $k => $v) {
                    $prefix = static::getNestedCats($k, $v, $prefix, $solution);
                }
            }

            return $p;
        }
    }

    /**
     * Get manufacturer name
     *
     * @param Product $product
     *
     * @return string
     */
    protected static function getManufacturerName($product)
    {
        return Manufacturer::getNameById((int) $product->id_manufacturer);
    }

    /**
     * Get supplier name
     *
     * @param Product $product
     *
     * @return string
     */
    protected static function getSupplierName($product)
    {
        return (string) $product->supplier_name;
    }

    /**
     * Get trimmed reference
     *
     * @param Product $product
     *
     * @return string
     *
     * @todo: figure out if we can also use an untrimmed reference
     */
    protected static function getTrimmedRef($product)
    {
        return (string) substr($product->reference, 3, strlen($product->reference));
    }

    /**
     * Get on sale flag
     *
     * @param Product $product
     *
     * @return bool
     */
    protected static function getOnSale($product)
    {
        return (bool) $product->on_sale;
    }

    /**
     * Get available now flag
     *
     * @param Product $product
     *
     * @return bool
     */
    protected static function getAvailableNow($product)
    {
        return (bool) $product->available_now;
    }

    /**
     * Get the base price of a product
     *
     * @param int $idProduct
     *
     * @return float
     */
    protected static function getProductBasePrice($idProduct)
    {
        return (float) Db::getInstance(_PS_USE_SQL_SLAVE_)->getValue(
            (new DbQuery())
                ->select('ps.`price`')
                ->from('product', 'p')
                ->innerJoin('product_shop', 'ps', 'ps.`id_product` = p.`id_product` AND ps.`id_shop` = '.(int) Context::getContext()->shop->id)
                ->where('p.`id_product` = '.(int) $idProduct)
        );
    }
}
