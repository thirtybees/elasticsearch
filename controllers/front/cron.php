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
    if (php_sapi_name() !== 'cli') {
        exit;
    } else {
        require_once __DIR__.'/../../../../config/config.inc.php';
    }
}

/**
 * Class ElasticsearchcronModuleFrontController
 */
class ElasticsearchcronModuleFrontController extends ModuleFrontController
{
    /**
     * Run the cron job
     *
     * ElasticsearchcronModuleFrontController constructor.
     */
    public function __construct()
    {
        // Use admin user for indexing
        Context::getContext()->employee = new Employee(Db::getInstance(_PS_USE_SQL_SLAVE_)->getValue(
            (new DbQuery())
                ->select('`'.bqSQL(Employee::$definition['primary']).'`')
                ->from(bqSQL(Employee::$definition['table']))
                ->where('`id_profile` = 1')
        ));

        $chunks = INF;
        if (isset($_GET['chunks'])) {
            $chunks = (int) $_GET['chunks'];
        }

        /** @var Elasticsearch $module */
        $module = Module::getInstanceByName('elasticsearch');
        $module->cronProcessRemainingProducts($chunks);
    }
}

if (php_sapi_name() === 'cli') {
    new ElasticsearchcronModuleFrontController();
}
