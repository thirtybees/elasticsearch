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

use AttributeGroup;
use Category;
use Configuration;
use Group;
use Context;
use Customer;
use Db;
use DbQuery;
use Image;
use ImageType;
use Link;
use Logger;
use Manufacturer;
use Page;
use PrestaShopException;
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
        'allow_oosp'              => [
            'function'      => [__CLASS__, 'getAllowOosp'],
            'default'       => Meta::ELASTIC_TYPE_BOOLEAN,
            'elastic_types' => [
                Meta::ELASTIC_TYPE_BOOLEAN,
            ],
            'visible'       => false,
        ],
        'available_for_order'     => [
            'function'      => [__CLASS__, 'getAvailableForOrder'],
            'default'       => Meta::ELASTIC_TYPE_BOOLEAN,
            'elastic_types' => [
                Meta::ELASTIC_TYPE_BOOLEAN,
            ],
            'visible'       => false,
        ],
        'available_now'           => [
            'function'      => [__CLASS__, 'getAvailableNow'],
            'default'       => Meta::ELASTIC_TYPE_KEYWORD,
            'elastic_types' => [
                Meta::ELASTIC_TYPE_KEYWORD,
            ],
        ],
        'available_later'           => [
            'function'      => [__CLASS__, 'getAvailableLater'],
            'default'       => Meta::ELASTIC_TYPE_KEYWORD,
            'elastic_types' => [
                Meta::ELASTIC_TYPE_KEYWORD,
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
        'categories_without_path' => [
            'function'      => [__CLASS__, 'getCategoriesNamesWithoutPath'],
            'default'       => Meta::ELASTIC_TYPE_TEXT,
            'elastic_types' => [
                Meta::ELASTIC_TYPE_KEYWORD,
                Meta::ELASTIC_TYPE_TEXT,
            ],
        ],
        'color_list'              => [
            'function'      => null,
            'default'       => Meta::ELASTIC_TYPE_KEYWORD,
            'elastic_types' => [
                Meta::ELASTIC_TYPE_KEYWORD,
            ],
            'visible'       => false,
        ],
        'condition'               => [
            'function'      => null,
            'default'       => Meta::ELASTIC_TYPE_KEYWORD,
            'visible'       => false,
            'elastic_types' => [
                Meta::ELASTIC_TYPE_KEYWORD,
            ],
        ],
        'customization_required'  => [
            'function'      => [__CLASS__, 'getCustomizationRequired'],
            'default'       => Meta::ELASTIC_TYPE_BOOLEAN,
            'elastic_types' => [
                Meta::ELASTIC_TYPE_BOOLEAN,
            ],
            'visible'       => false,
        ],
        'date_add'                => [
            'function'      => null,
            'default'       => Meta::ELASTIC_TYPE_DATE,
            'elastic_types' => [
                Meta::ELASTIC_TYPE_DATE,
            ],
        ],
        'date_upd'                => [
            'function'      => null,
            'default'       => Meta::ELASTIC_TYPE_DATE,
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
            'function'      => [__CLASS__, 'generateImageLinkLarge'],
            'default'       => Meta::ELASTIC_TYPE_KEYWORD,
            'visible'       => false,
            'elastic_types' => [
                Meta::ELASTIC_TYPE_KEYWORD,
            ],
        ],
        'image_link_small'        => [
            'function'      => [__CLASS__, 'generateImageLinkSmall'],
            'default'       => Meta::ELASTIC_TYPE_KEYWORD,
            'visible'       => false,
            'elastic_types' => [
                Meta::ELASTIC_TYPE_KEYWORD,
            ],
        ],
        'in_stock'                => [
            'function'      => [__CLASS__, 'getInStock'],
            'default'       => Meta::ELASTIC_TYPE_BOOLEAN,
            'elastic_types' => [
                Meta::ELASTIC_TYPE_BOOLEAN,
            ],
            'visible'       => false,
        ],
        'is_virtual'              => [
            'function'      => [__CLASS__, 'getIsVirtual'],
            'default'       => Meta::ELASTIC_TYPE_BOOLEAN,
            'elastic_types' => [
                Meta::ELASTIC_TYPE_BOOLEAN,
            ],
        ],
        'link'                    => [
            'function'      => [__CLASS__, 'generateLinkRewrite'],
            'default'       => Meta::ELASTIC_TYPE_KEYWORD,
            'visible'       => false,
            'elastic_types' => [
                Meta::ELASTIC_TYPE_KEYWORD,
            ],
        ],
        'id_tax_rules_group'      => [
            'function'      => null,
            'default'       => Meta::ELASTIC_TYPE_INTEGER,
            'visible'       => false,
            'elastic_types' => [
                Meta::ELASTIC_TYPE_INTEGER,
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
        'minimal_quantity'        => [
            'function'      => [__CLASS__, 'getMinimalQuantity'],
            'default'       => Meta::ELASTIC_TYPE_INTEGER,
            'elastic_types' => [
                Meta::ELASTIC_TYPE_INTEGER,
            ],
            'visible'       => false,
        ],
        'new'                     => [
            'function'      => [__CLASS__, 'getNew'],
            'default'       => Meta::ELASTIC_TYPE_BOOLEAN,
            'elastic_types' => [
                Meta::ELASTIC_TYPE_BOOLEAN,
            ],
        ],
        'price_tax_excl'          => [
            'function'      => [__CLASS__, 'getPriceTaxExcl'],
            'default'       => Meta::ELASTIC_TYPE_FLOAT,
            'elastic_types' => [
                Meta::ELASTIC_TYPE_FLOAT,
            ],
        ],
        'show_price'              => [
            'function'      => [__CLASS__, 'getShowPrice'],
            'default'       => Meta::ELASTIC_TYPE_BOOLEAN,
            'elastic_types' => [
                Meta::ELASTIC_TYPE_BOOLEAN,
            ],
            'visible'       => false,
        ],
        'supplier'                => [
            'function'      => [__CLASS__, 'getSupplierName'],
            'default'       => Meta::ELASTIC_TYPE_TEXT,
            'elastic_types' => [
                Meta::ELASTIC_TYPE_KEYWORD,
                Meta::ELASTIC_TYPE_TEXT,
            ],
        ],
        'on_sale'                 => [
            'function'      => [__CLASS__, 'getOnSale'],
            'default'       => Meta::ELASTIC_TYPE_BOOLEAN,
            'elastic_types' => [
                Meta::ELASTIC_TYPE_BOOLEAN,
            ],
        ],
        'online_only'             => [
            'function'      => [__CLASS__, 'getOnlineOnly'],
            'default'       => Meta::ELASTIC_TYPE_BOOLEAN,
            'elastic_types' => [
                Meta::ELASTIC_TYPE_BOOLEAN,
            ],
        ],
        'ordered_qty'             => [
            'function'      => [__CLASS__, 'getOrderedQty'],
            'default'       => Meta::ELASTIC_TYPE_INTEGER,
            'visible'       => false,
            'elastic_types' => [
                Meta::ELASTIC_TYPE_INTEGER,
            ],
        ],
        'stock_qty'               => [
            'function'      => [__CLASS__, 'getStockQty'],
            'default'       => Meta::ELASTIC_TYPE_INTEGER,
            'visible'       => false,
            'elastic_types' => [
                Meta::ELASTIC_TYPE_INTEGER,
            ],
        ],
        'weight'                  => [
            'function'      => null,
            'default'       => Meta::ELASTIC_TYPE_FLOAT,
            'visible'       => false,
            'elastic_types' => [
                Meta::ELASTIC_TYPE_FLOAT,
            ],
        ],
        'pageviews'               => [
            'function'      => [__CLASS__, 'getPageViews'],
            'default'       => Meta::ELASTIC_TYPE_INTEGER,
            'elastic_types' => [
                Meta::ELASTIC_TYPE_INTEGER,
            ],
        ],
        'sales'                   => [
            'function'      => [__CLASS__, 'getSales'],
            'default'       => Meta::ELASTIC_TYPE_INTEGER,
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
     * @throws \PrestaShopException
     */
    public static function initProduct($idProduct, $idLang)
    {
        $elasticProduct = new stdClass();
        $elasticProduct->id = (int) $idProduct;
        $product = new Product($idProduct, true, $idLang);
        if (!\Validate::isLoadedObject($product)) {
            return $elasticProduct;
        }
        $products = [$product];
        static::addColorListHTML($products);
        $idLangDefault = (int) Configuration::get('PS_LANG_DEFAULT');

        $metas = [];
        try {
            foreach (Db::getInstance(_PS_USE_SQL_SLAVE_)->executeS(
                (new DbQuery())
                    ->select('*')
                    ->from(bqSQL(Meta::$definition['table']))
            ) as $meta) {
                $metas[$meta['alias']] = $meta;
            }
        } catch (PrestaShopException $e) {
            Logger::addLog("Elasticsearch module error: {$e->getMessage()}");
        }

        // Default properties
        $propertyAliases = \Elasticsearch::getAliases(array_keys(static::$attributes));
        foreach (static::$attributes as $propName => $propItems) {
            $propAlias = $propertyAliases[$propName];
            if (!$metas[$propAlias]['enabled'] && !in_array($propName, [
                $propertyAliases['date_add'],
                $propertyAliases['date_upd'],
                $propertyAliases['price_tax_excl'],
                $propertyAliases['id_tax_rules_group'],
            ])) {
                continue;
            }

            if ($propItems['function'] != null && method_exists($propItems['function'][0], $propItems['function'][1])) {
                $elasticProduct->{$propAlias} = call_user_func($propItems['function'], $product, $idLang);

                continue;
            }
            if (!$propName) {
                continue;
            }

            if (isset(Product::$definition[$propName]['lang']) == true) {
                $elasticProduct->{$propAlias} = $product->{$propName}[$idLang];
            } else {
                $elasticProduct->{$propAlias} = $product->{$propName};
            }
        }

        // Features
        try {
            foreach ($product->getFrontFeatures($idLang) as $feature) {
                $name = Tools::link_rewrite($feature['name']);
                if (!$name) {
                    continue;
                }

                if ($idLang === $idLangDefault) {
                    $featureCode = $name;
                } else {
                    $frontFeature = array_filter(Product::getFrontFeaturesStatic($idLangDefault, $product->id), function ($item) use ($feature) {
                        return $item['id_feature'] == $feature['id_feature'];
                    });
                    $featureCode = Tools::link_rewrite(current($frontFeature)['name']);
                }
                $featureAlias = \Elasticsearch::getAlias($featureCode, 'feature');
                if (!$metas[$featureAlias]['enabled']) {
                    continue;
                }

                $propItems = $feature['value'];

                $elasticProduct->{$featureAlias} = $propItems;
            }
        } catch (PrestaShopException $e) {
            Logger::addLog("Elasticsearch module error: {$e->getMessage()}");
        }

        // Attribute groups
        try {
            $attributeGroups = $product->getAttributesGroups($idLang);
            $groupNames = array_map(function ($attribute) {
                return Tools::link_rewrite($attribute['group_name']);
            }, $attributeGroups);
            $attributeAliases = \Elasticsearch::getAliases($groupNames, 'attribute');
            if (count($groupNames) === count($attributeAliases)) {
                foreach (array_combine($attributeAliases, $attributeGroups) as $groupName => $attribute) {
                    if (!$metas[$groupName]['enabled']) {
                        continue;
                    }

                    $attributeName = $attribute['attribute_name'];
                    if ($idLang === $idLangDefault) {
                        $attributeCode = $groupName;
                    } else {
                        $attributeGroup = new AttributeGroup($attribute['id_attribute_group'], $idLangDefault);
                        $attributeCode = Tools::link_rewrite($attributeGroup->name);
                    }
                    $attributeAlias = \Elasticsearch::getAlias($attributeCode, 'attribute');

                    if (!isset($elasticProduct->{$attributeAlias}) || !is_array($elasticProduct->{$attributeAlias})) {
                        $elasticProduct->{$attributeAlias} = [];
                    }

                    if (!in_array($attributeName, $elasticProduct->{$groupName})) {
                        $elasticProduct->{$attributeAlias}[] = $attributeName;
                    }

                    if ($attribute['is_color_group']) {
                        // Add a special property for the color group
                        // We assume [ yes, we are assuming something, I know :) ] that the color names and color codes
                        // will eventually be in the same order, so that's how you can match them later
                        if (!isset($elasticProduct->{"{$attributeAlias}_color_code"}) || !is_array($elasticProduct->{"{$attributeAlias}_color_code"})) {
                            $elasticProduct->{"{$attributeAlias}_color_code"} = [];
                        }

                        if (!in_array($attribute['attribute_color'], $elasticProduct->{"{$attributeAlias}_color_code"})) {
                            $elasticProduct->{"{$attributeAlias}_color_code"}[] = $attribute['attribute_color'];
                        }
                    }
                }
            }
        } catch (PrestaShopException $e) {
            Logger::addLog("Elasticsearch module error: {$e->getMessage()}");
        }

        // Filter metas
        foreach ($metas as $code => $meta) {
            if (!$meta['enabled'] && isset(static::$attributes[$code]['visible']) && static::$attributes[$code]['visible']) {
                unset($elasticProduct->{$meta['alias']});
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
        try {
            return Db::getInstance(_PS_USE_SQL_SLAVE_)->getValue(
                (new DbQuery())
                    ->select('IFNULL(SUM(pv.`counter`), 0)')
                    ->from('page', 'pa')
                    ->leftJoin('page_viewed', 'pv', 'pa.`id_page` = pv.`id_page`')
                    ->where('pa.`id_object` = '.(int) $product->id)
                    ->where('pa.`id_page_type` = '.(int) Page::getPageTypeByName('product'))
            );
        } catch (PrestaShopException $e) {
            Logger::addLog("Elasticsearch module error: {$e->getMessage()}");

            return 0;
        }

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
        try {
            $sales = ProductSale::getNbrSales($product->id);
        } catch (PrestaShopException $e) {
            Logger::addLog("Elasticsearch module error: {$e->getMessage()}");

            return 0;
        }

        return $sales > 0 ? $sales : 0;
    }

    /**
     * Get category path
     *
     * @param int $idCategory
     * @param int $idLang
     *
     * @return array
     */
    public static function getCategoryPathArray($idCategory, $idLang)
    {
        $cats = [];
        try {
            $interval = Category::getInterval($idCategory);
        } catch (PrestaShopException $e) {
            Logger::addLog("Elasticsearch module error: {$e->getMessage()}");

            $interval = 0;
        }

        if ($interval) {
            try {
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
            } catch (PrestaShopException $e) {
                Logger::addLog("Elasticsearch module error: {$e->getMessage()}");
            }

            foreach ($categories as $category) {
                $cats[] = $category;
            }
        }

        static::getNestedCats(0, $cats, '', $results);
        if (count($results) < 3) {
            return [];
        }

        return array_splice($results, 1);
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
        try {
            $interval = Category::getInterval($idCategory);
        } catch (PrestaShopException $e) {
            Logger::addLog("Elasticsearch module error: {$e->getMessage()}");

            $interval = false;
        }

        if ($interval) {
            try {
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
            } catch (PrestaShopException $e) {
                Logger::addLog("Elasticsearch module error: {$e->getMessage()}");
            }

            foreach ($categories as $category) {
                $cats[] = $category;
            }
        }

        return $cats;
    }

    /**
     * Get stock quantity
     */
    protected static function getStockQty($product)
    {
        try {
            return Product::getQuantity($product->id);
        } catch (PrestaShopException $e) {
            Logger::addLog("Elasticsearch module error: {$e->getMessage()}");

            return 0;
        }
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

        try {
            return (int) Db::getInstance(_PS_USE_SQL_SLAVE_)->getValue(
                (new DbQuery())
                    ->select('SUM(`product_quantity`) AS `total`')
                    ->from('order_detail')
                    ->where('`product_id` = '.(int) $product->id)
            );
        } catch (PrestaShopException $e) {
            Logger::addLog("Elasticsearch module error: {$e->getMessage()}");

            return 0;
        }
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
        try {
            $prices = [
                'group_0' => (float) static::getProductBasePrice($product->id),
                'group_1' => (float) Product::getPriceStatic($product->id, false, null, _TB_PRICE_DATABASE_PRECISION_),
            ];
        } catch (PrestaShopException $e) {
            Logger::addLog("Elasticsearch module error: {$e->getMessage()}");

            return [];
        }
        try {
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
        } catch (PrestaShopException $e) {
            Logger::addLog("Elasticsearch module error: {$e->getMessage()}");

            return [];
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
        try {
            $cover = Image::getCover($product->id);
        } catch (PrestaShopException $e) {
            Logger::addLog("Elasticsearch module error: {$e->getMessage()}");

            return '';
        }

        try {
            if ($cover['id_image']) {
                $imageLink = $link->getImageLink(
                    $product->link_rewrite[$idLang],
                    $cover['id_image'],
                    ImageType::getFormatedName('large')
                );
            } else {
                $imageLink = Tools::getHttpHost()._THEME_PROD_DIR_.'en-default-large_default.jpg';
            }
        } catch (PrestaShopException $e) {
            Logger::addLog("Elasticsearch module error: {$e->getMessage()}");

            return '';
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
        try {
            $cover = Image::getCover($product->id);
        } catch (PrestaShopException $e) {
            Logger::addLog("Elasticsearch module error: {$e->getMessage()}");

            return '';
        }

        try {
            if ($cover['id_image']) {
                $imageLink = $link->getImageLink(
                    $product->link_rewrite[$idLang],
                    $cover['id_image'],
                    ImageType::getFormatedName('small')
                );
            } else {
                $imageLink = Tools::getHttpHost()._THEME_PROD_DIR_.'en-default-small_default.jpg';
            }
        } catch (PrestaShopException $e) {
            Logger::addLog("Elasticsearch module error: {$e->getMessage()}");

            return '';
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

    /**
     * @param Product $product
     *
     * @return bool
     */
    protected static function getAllowOosp($product)
    {
        try {
            return (bool) Product::isAvailableWhenOutOfStock($product->out_of_stock);
        } catch (PrestaShopException $e) {
            Logger::addLog("Elasticsearch module error: {$e->getMessage()}");

            return false;
        }
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
        try {
            $cats = Db::getInstance(_PS_USE_SQL_SLAVE_)->executeS(
                (new DbQuery())
                    ->select('c.*, cl.*')
                    ->from('category', 'c')
                    ->join(Shop::addSqlAssociation('category', 'c'))
                    ->leftJoin(
                        'category_lang',
                        'cl',
                        'c.`id_category` = cl.`id_category`'.Shop::addSqlRestrictionOnLang('cl')
                    )
                    ->leftJoin(
                        'category_product',
                        'cp',
                        'cp.`id_category` = c.`id_category` AND cp.`id_product` = '.(int) $product->id
                    )
                    ->where('`id_lang` = '.(int) $idLang)
                    ->where('c.`active` = 1')
                    ->orderBy('c.`level_depth` ASC, category_shop.`position` ASC')
            );
        } catch (PrestaShopException $e) {
            Logger::AddLog("Elasticsearch module error: {$e->getMessage()}");

            $cats = [];
        }

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
        if (!is_array($solution)) {
            $solution = [];
        }

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
     * @param Product $product
     *
     * @return bool
     */
    protected static function getCustomizationRequired($product)
    {
        return (bool) $product->customization_required;
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
        try {
            return Manufacturer::getNameById((int) $product->id_manufacturer);
        } catch (PrestaShopException $e) {
            Logger::addLog("Elasticsearch module error: {$e->getMessage()}");

            return '';
        }
    }

    /**
     * Get minimal quantity to order
     *
     * @param Product $product
     *
     * @return bool
     */
    protected static function getMinimalQuantity($product)
    {
        return (int) $product->minimal_quantity;
    }

    /**
     * Get `show_price` flag
     *
     * @param Product $product
     *
     * @return bool
     */
    protected static function getShowPrice($product)
    {
        return (bool) $product->show_price;
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
     * Get is_virtual flag
     *
     * @param Product $product
     *
     * @return bool
     */
    protected static function getIsVirtual($product)
    {
        return (bool) $product->is_virtual;
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
     * Get online only flag
     *
     * @param Product $product
     *
     * @return bool
     */
    protected static function getOnlineOnly($product)
    {
        return (bool) $product->online_only;
    }

    /**
     * Get available_for_order flag
     *
     * @param Product $product
     *
     * @return bool
     */
    protected static function getAvailableForOrder($product)
    {
        return (bool) $product->available_for_order;
    }

    /**
     * @param Product $product
     *
     * @return bool
     */
    protected static function getNew($product)
    {
        return (bool) $product->new;
    }

    /**
     * Get `available_now` flag
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
     * Get `available_later` flag
     *
     * @param Product $product
     *
     * @return bool
     */
    protected static function getAvailableLater($product)
    {
        return (bool) $product->available_later;
    }

    /**
     * Get in stock flag
     *
     * @param Product $product
     *
     * @return bool
     */
    protected static function getInStock($product)
    {
        try {
            return (bool) Product::getQuantity($product->id) > 0;
        } catch (PrestaShopException $e) {
            Logger::addLog("Elasticsearch module error: {$e->getMessage()}");

            return false;
        }
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
        try {
            return (float) Db::getInstance(_PS_USE_SQL_SLAVE_)->getValue(
                (new DbQuery())
                    ->select('ps.`price`')
                    ->from('product', 'p')
                    ->innerJoin(
                        'product_shop',
                        'ps',
                        'ps.`id_product` = p.`id_product` AND ps.`id_shop` = '.(int) Context::getContext()->shop->id
                    )
                    ->where('p.`id_product` = '.(int) $idProduct)
            );
        } catch (PrestaShopException $e) {
            Logger::addLog("Elasticsearch module error: {$e->getMessage()}");

            return 0;
        }
    }

    /**
     * Renders and adds color list HTML for each product in a list.
     *
     * @param Product[] $products
     *
     * @since   1.0.0
     *
     * @version 1.0.0 Initial version
     */
    protected static function addColorListHTML(&$products)
    {
        if (!is_array($products) || !count($products) || !file_exists(_PS_THEME_DIR_.'product-list-colors.tpl')) {
            return;
        }

        $productsNeedCache = [];
        foreach ($products as &$product) {
            $productsNeedCache[] = (int) $product->id;
        }
        unset($product);

        try {
            Tools::enableCache();
        } catch (PrestaShopException $e) {
        }
        foreach ($products as &$product) {
            $colors = false;
            if (count($productsNeedCache)) {
                $colors = static::getAttributesColorList($productsNeedCache, true, $product->elastic_id_lang);
            }
            $tpl = Context::getContext()->smarty->createTemplate(
                \Elasticsearch::tpl('front/product-list-colors.tpl'),
                Product::getColorsListCacheId($product->id)
            );
            if (isset($colors[$product->id])) {
                $tpl->assign(
                    [
                        'id_product'  => $product->id,
                        'id_lang'     => $product->elastic_id_lang,
                        'colors_list' => $colors[$product->id],
                        'link'        => Context::getContext()->link,
                        'img_col_dir' => _THEME_COL_DIR_,
                        'col_img_dir' => _PS_COL_IMG_DIR_,
                    ]
                );
            }

            if (!in_array($product->id, $productsNeedCache) || isset($colors[$product->id])) {
                $product->color_list = $tpl->fetch(
                    \Elasticsearch::tpl('front/product-list-colors.tpl'),
                    Product::getColorsListCacheId($product->id)
                );
            } else {
                $product->color_list = '';
            }
        }
        Tools::restoreCacheSettings();
    }

    /**
     * @param array $products
     * @param bool  $haveStock
     *
     * @return array|bool
     *
     * @since   1.0.0
     * @version 1.0.0 Initial version
     */
    protected static function getAttributesColorList(array $products, $haveStock = true, $idLang = null)
    {
        if (!count($products)) {
            return [];
        }

        if (!$idLang) {
            $idLang = Context::getContext()->language->id;
        }

        try {
            $checkStock = !Configuration::get('PS_DISP_UNAVAILABLE_ATTR');
        } catch (PrestaShopException $e) {
            Logger::addLog("Elasticsearch module error: {$e->getMessage()}");

            return false;
        }
        try {
            if (!$res = Db::getInstance()->executeS(
                '
                SELECT pa.`id_product`, a.`color`, pac.`id_product_attribute`, '.($checkStock ? 'SUM(IF(stock.`quantity` > 0, 1, 0))' : '0').' qty, a.`id_attribute`, al.`name`, IF(color = "", a.id_attribute, color) group_by
                FROM `'._DB_PREFIX_.'product_attribute` pa
                '.Shop::addSqlAssociation('product_attribute', 'pa').($checkStock ? Product::sqlStock('pa', 'pa') : '').'
                JOIN `'._DB_PREFIX_.'product_attribute_combination` pac ON (pac.`id_product_attribute` = product_attribute_shop.`id_product_attribute`)
                JOIN `'._DB_PREFIX_.'attribute` a ON (a.`id_attribute` = pac.`id_attribute`)
                JOIN `'._DB_PREFIX_.'attribute_lang` al ON (a.`id_attribute` = al.`id_attribute` AND al.`id_lang` = '.(int) $idLang.')
                JOIN `'._DB_PREFIX_.'attribute_group` ag ON (a.id_attribute_group = ag.`id_attribute_group`)
                WHERE pa.`id_product` IN ('.implode(array_map('intval', $products), ',').') AND ag.`is_color_group` = 1
                GROUP BY pa.`id_product`, a.`id_attribute`, `group_by`
                '.($checkStock ? 'HAVING qty > 0' : '').'
                ORDER BY a.`position` ASC;'
            )
            ) {
                return false;
            }
        } catch (PrestaShopException $e) {
            Logger::addLog("Elasticsearch module error: {$e->getMessage()}");

            return false;
        }

        $colors = [];
        foreach ($res as $row) {
            if (Tools::isEmpty($row['color']) && !@filemtime(_PS_COL_IMG_DIR_.$row['id_attribute'].'.jpg')) {
                continue;
            }

            $colors[(int) $row['id_product']][] = [
                'id_product_attribute' => (int) $row['id_product_attribute'],
                'color' => $row['color'],
                'id_product' => $row['id_product'],
                'name' => $row['name'],
                'id_attribute' => $row['id_attribute']
            ];
        }

        return $colors;
    }
}
