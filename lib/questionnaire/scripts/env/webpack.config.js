const path = require('path');

const plugin_path = process.env.PLUGIN;
const file = process.env.FILE;

module.exports = {
    mode: 'development',
    target: 'node',

    entry: file,
    output: {
        filename: '.script.js',
        path: __dirname
    },

    resolve: {
        extensions: ['.js', '.json',],
        alias: {
            QUESTIONNAIRE_SRC: path.resolve(__dirname, '../../src'),
            NODE_MODULES: path.resolve(__dirname, './node_modules'),
            PLUGIN_SRC: path.resolve(plugin_path, './src'),
        }
    },

    module: {
        rules: [
            { test: /\.csv$/, use: ['csv-loader'] },
        ]
    },

};
