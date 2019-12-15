<template>
    <div>

        <div
         class="aggrs-map mt-3">
            <div
             class="alert-holder">
                <v-alert
                 :value="currentGeoData.status === 'l'"
                 type="info"
                 v-t="'processing.loading'"/>
                <v-alert
                 :value="currentGeoData.status === 'f'"
                 type="error"
                 v-t="'processing.no_data'"/>
            </div>
            <open-layer-map
             @connect="mapConnected"/>
        </div>

        <div
         v-if="dataPresent"
         class="aggrs-table mt-3">
            <div
             class="headline">
                {{$t('views.overview.map.listing')}} ({{selected.length}} {{levelText}}) :
            </div>
            <div
             class="-detail-listing">
                <div
                 v-for="{region, value, css} in selectedRegionsData"
                 :key="region.full_code"
                 class="d-flex f-align-center">
                    <div
                     class="f0 -num"
                     :style="css">
                        {{formatNumber(value)}}
                    </div>
                    <div>
                        {{region.fullRegionName()}}
                    </div>
                </div>
            </div>
        </div>

    </div>
</template>

<script>
    import Vue from 'vue';
    import GeoJsonMap from '../../lib/map/geo_json_map';
    import * as ol_style from 'ol/style.js';

    import * as indicators_lib from './indicators';

    const GEOJSON = {
        l1: require('!!file-loader?name=static/geo/l1.[hash:8].json!PLUGIN_SRC/assets/l1.geo'),
        l2: require('!!file-loader?name=static/geo/l2.[hash:8].json!PLUGIN_SRC/assets/l2.geo'),
        l3: require('!!file-loader?name=static/geo/l3.[hash:8].json!PLUGIN_SRC/assets/l3.geo'),
    };

    export default {

        props: [
            'regions-data',
            'selected',
            'schema',
            'sort',
        ],

        data () {
            return {
                connected: false,
                map: null,
                geoData: {
                    'l1': new GeoData('l1'),
                    'l2': new GeoData('l2'),
                    'l3': new GeoData('l3'),
                },
                loading: false
            }
        },

        computed: {
            dataPresent () {
                return !!this.schema;
            },

            values () {
                const {indicators, regions} = this.regionsData;
                if (!this.dataPresent) return {};

                const values = Object.assign({}, indicators);
                regions.forEach(region =>
                    values[region.full_code] = values[region.full_code]
                        .summary(this.schema)
                        .total
                );
                return values;
            },

            levelText () {
                switch (this.regionsData.level_name) {
                    case 'l1': return this.$t('records.geography.provs');
                    case 'l2': return this.$t('records.geography.muns');
                    case 'l3': return this.$t('records.geography.coms');
                }
            },

            styles () {
                return new StylesIndex(
                    this.values
                );
            },

            currentGeoData () {
                return this.geoData[this.regionsData.level_name];
            },

            selectedRegionsData () {
                const {indicators, regions} = this.regionsData;

                const regions_index = regions.reduce(
                    (acc, region) => {
                        acc[region.full_code] = region;
                        return acc;
                    },
                    {}
                );

                const data = this.selected
                    .map(reg_id => {
                        const value = indicators[reg_id].summary(this.schema).total;

                        return {
                            region: regions_index[reg_id],
                            value,
                            css: (indicators_lib.isBad(value) ?
                                { backgroundColor: indicators_lib.color(value) } :
                                null)
                        }
                    });

                const sort_mod = this.sort === 'desc' ? -1 : 1;
                data.sort((a, b) => sort_mod * (a.value - b.value));
                return data;
            }

        },

        watch: {
            regionsData () { this.updateMap(); },
            selected () { this.updateMap(); },
            schema () { this.updateMap(); },
            sort () { this.updateMap(); },
        },

        methods: {

            mapConnected (e) {
                if (this.map) throw 'reconnection?';

                Vue.nextTick(() => {
                    this.map = Object.freeze(new GeoJsonMap(e.detail));
                    this.connected = true;
                    this.updateMap();
                });
            },

            updateMap () {
                const geo_data = this.currentGeoData;
                if (!geo_data) {
                    this.map.removeLayer('regions');
                    return;
                }

                switch (geo_data.status) {
                    case 'n':
                        geo_data.loadData(() => this.updateMap());
                        return;

                    case 'y':
                        this.map.setLayer('regions', 'vector', {
                            source: GeoJsonMap.vSourceFromGeoJson(geo_data.data),
                            style: feature => {
                                const code = feature.get('adm');
                                if (this.selected.includes(code)) {
                                    return this.styles.get(code);
                                } else {
                                    return NO_DATA_STYLE;
                                }
                            }
                        });
                        return;

                    case 'f':
                        this.map.removeLayer('regions');
                        return;
                }
            },

            formatNumber (value) {
                return value.toFixed(2);
            }

        }

    }

    const BORDER_STYLE = new ol_style.Stroke({
        color: 'rgba(0.5, 0.5, 0.5, 0.1)',
        width: 1
    });
    const NO_DATA_STYLE = new ol_style.Style({
        stroke: BORDER_STYLE,
        fill: new ol_style.Fill({
            color: 'rgba(0.5, 0.5, 0.5, 0.05)'
        })
    });

    class StylesIndex {

        constructor (values) {
            this.values = values;

            this.styles = {};
            for (const grade in indicators_lib.colors) {
                const color = indicators_lib.colors[grade];
                this.styles[grade] = new ol_style.Style({
                    stroke: BORDER_STYLE,
                    fill: new ol_style.Fill({ color: `${color}80` })
                });
            }
        }

        get (group) {
            const grade = indicators_lib.grade(this.values[group]);
            return this.styles[grade] || NO_DATA_STYLE;
        }

    }

    class GeoData {

        constructor (level) {
            this.name = level;
            this.status = 'n';
            this.data = null;
        }

        async loadData (callback) {
            this.status = 'l';

            try {
                const url = GEOJSON[this.name];
                if (!url) {
                    throw `no map redgions geojson for level ${this.name}`;
                }

                const response = await fetch(
                    url,
                    {
                        method: 'GET',
                        headers: {'Content-type': 'application/json'}
                    }
                );
                this.data = Object.freeze(await response.json());
                this.status = 'y';

            } catch (e) {
                console.error(e);
                this.status = 'f';

            }

            callback();
        }

    }

</script>
