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

if (!defined('_TB_VERSION_')) {
    exit;
}

/**
 * Class ElasticsearchsearchModuleFrontController
 */
class ElasticsearchsearchModuleFrontController extends ModuleFrontController
{
    // @codingStandardsIgnoreStart
    /** @var bool Place a column on the left by default, regardless of the store's default settings */
    public $display_column_left = false;
    // @codingStandardsIgnoreEnd

    /**
     * Initialize content
     */
    public function initContent()
    {
        $this->addCSS(
            [
                _THEME_CSS_DIR_.'scenes.css'       => 'all',
                _THEME_CSS_DIR_.'category.css'     => 'all',
                _THEME_CSS_DIR_.'product_list.css' => 'all',
            ]
        );

        $this->setTemplate('search.tpl');

        parent::initContent();
    }
}
