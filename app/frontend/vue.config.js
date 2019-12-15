const env = process.env.NODE_ENV;

const webpack = require('webpack');
const path = require('path');

const APP_ROOT = path.resolve(__dirname, '../..');
const OQ_LIB = path.resolve(APP_ROOT, 'lib/questionnaire');

// const StatsPlugin = require('stats-webpack-plugin');

module.exports = {

    pluginOptions: {
        i18n: {
            locale: 'en',
            localeDir: 'locales'
        }
    },

    devServer: {
        proxy: {
            '^/app/': {
                target: 'http://localhost:3000',
                changeOrigin: true
            }
        }
    },

    assetsDir: 'static/',
    outputDir: path.resolve(APP_ROOT, 'app/frontend/build'),

    chainWebpack: config => {

        config
            .resolve.alias
            .set('PLUGIN_SRC', path.resolve(OQ_LIB, 'plugin/src'))
            .set('QUESTIONNAIRE_SRC', path.resolve(OQ_LIB, 'src'));

        config
            .plugin('provide')
            .use(
                webpack.ProvidePlugin,
                [{
                    FORM_DEFINITION: ['PLUGIN_SRC/ema_form', 'default']
                }]
            );

        config
            .module
            .rule('images')
            .use('url-loader')
            .loader('url-loader')
            .tap(options => {
                options.limit = -1;
                return options
            });

        config
            .module
            .rule('csv')
            .test(/\.csv$/)
            .use('csv-loader')
            .loader('csv-loader');

        // config
        //     .plugin('stats_plugin')
        //     .use(new StatsPlugin('stats.json'), [{chunkModules: true}]);

        if (env === 'development') {
            config
                .devtool('cheap-eval-source-map');
        }
    }
};
