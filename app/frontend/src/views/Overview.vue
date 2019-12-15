<template>
    <v-container
     fluid
     class="page-overview">

        <div
         class="mb-3 elevation-1 pa-2">
            <records-filters
             @apply="fetchAggregations()"/>
        </div>

        <div
         class="mb-3 elevation-1 pa-2">
            <controls-table
             :controls="controls_definitions"
             :model="controls"
             :context="controlsContext"
             :t-prefix="controls_translation_prefix"/>
        </div>

        <v-alert
         :value="fetching === 'f'"
         type="error"
         v-t="'processing.server_fail'"/>

        <v-layout
         v-if="filteredSortedSchema && mergedFilteredData">

            <v-flex
             lg6
             class="ma-2">
                <aggregations-table
                 :indicators="mergedFilteredData"
                 :schema="filteredSortedSchema"/>
            </v-flex>

            <v-flex
             lg6
             class="ma-2">
                <color-scale/>

                <aggregations-map
                 :regions-data="dataGroupedByRegionLevel"
                 :selected="controls.regions"
                 :schema="filteredSortedSchema"
                 :sort="controls.sort"/>
            </v-flex>

        </v-layout>

    </v-container>
</template>

<script>
    import { mapState } from 'vuex';
    import { setDefaultStateSetter } from '../actions';

    import RecordsFilters from './records/RecordsFilters';
    import { filtersDefaultState, filterToQuery } from './records/filters/index';

    import * as ControlsTable from '../components/shared/controls_table/index';
    import IndicatorsSelection from './overview/controls/IndicatorsSelection';
    import SortOrderRadios from './overview/controls/SortOrderRadios';
    import GroupByRadios from './overview/controls/GroupByRadios';
    import RegionsSelection from './overview/controls/RegionsSelection';

    import AggregationsTable from './overview/AggregationsTable';
    import ColorScale from './overview/ColorScale';
    import AggregationsMap from './overview/AggregationsMap';

    setDefaultStateSetter('overview', current_state => ({
        data_filters: filtersDefaultState(current_state),

        fetching: 'n',
        data: null,
        controls: {
            indicators: 'all',
            sort: 'desc',
            group_by: '1',
            regions: []
        }
    }));

    export default {
        name: 'overview',

        components: {
            RecordsFilters,
            'controls-table': ControlsTable.ControlsTable,
            AggregationsTable,
            ColorScale,
            AggregationsMap,
        },

        data () {
            const controls_definitions = [
                new ControlsTable.Control('indicators', IndicatorsSelection),
                new ControlsTable.Control('sort', SortOrderRadios),
                new ControlsTable.Control('group_by', GroupByRadios),
                new ControlsTable.Control('regions', RegionsSelection),
            ];
            Object.freeze(controls_definitions);

            return {
                controls_definitions,
                controls_translation_prefix: 'views.overview.controls'
            }
        },

        watch: {
            dataGroupedByRegionLevel () {
                this.controls.regions = this.dataGroupedByRegionLevel
                    .regions
                    .map(region => region.full_code);
            }
        },

        mounted () {
            this.fetchAggregations();
        },

        computed: {
            ...mapState({
                controls: state => state.view.controls,
                fetching: state => state.view.fetching,

                loadedData (state) {
                    const raw_data = state.view.data;
                    const { getRegion } = FORM_DEFINITION.geography;

                    let schema = null, communes = [];
                    if (raw_data) {
                        schema = new IndicatorsGroupingSchema(raw_data.schema);
                        communes = Object.keys(raw_data.indicators)
                            .map(reg_id => ({
                                region: getRegion(reg_id),
                                indicators: raw_data.indicators[reg_id]
                            }))
                    }

                    return {
                        schema,
                        communes
                    };
                },
            }),

            dataGroupedByRegionLevel () {
                const { group_by } = this.controls;
                const { schema, communes } = this.loadedData;
                const { getRegion } = FORM_DEFINITION.geography;

                let indicators = {}, regions = [];

                if (communes) {
                    // collect same region's data into arrays
                    indicators = communes.reduce(
                        (acc, commune) => {
                            const reg_id = commune.region.fullCodeAtLevel(group_by);
                            addToGroup(acc, reg_id, commune.indicators);
                            return acc;
                        },
                        {}
                    );
                    // merge collected regions indicators
                    Object.keys(indicators).forEach(group =>
                        indicators[group] = Indicators.mergeGroup(
                            indicators[group],
                            schema.indicators
                        )
                    );

                    regions = Object.keys(indicators)
                        .map(reg_id => getRegion(reg_id));
                }

                return {
                    level_name: `l${group_by}`,
                    indicators,
                    regions
                }
            },

            controlsContext () {
                return {
                    indicatorsSchema: this.loadedData.schema,
                    allRegions: this.dataGroupedByRegionLevel.regions
                };
            },

            mergedFilteredData () {
                const { regions } = this.controls;
                const { schema } = this.loadedData;

                if (!schema || regions.length === 0) return;

                const { indicators } = this.dataGroupedByRegionLevel;
                return Indicators.mergeGroup(
                    regions.map(reg_id => indicators[reg_id].indicators),
                    schema.indicators
                );
            },

            filteredSortedSchema () {
                let { schema } = this.loadedData;
                if (!schema || !this.mergedFilteredData) return null;

                schema = this.loadedData.schema.clone();
                const { indicators, sort } = this.controls;
                if (indicators !== 'all') schema.selectInPlace(indicators);
                if (schema.isEmpty()) return null;

                schema.sortInPlace(
                    (sort === 'desc' ? -1 : 1),
                    this.mergedFilteredData
                );
                return schema;
            },
        },

        methods: {
            fetchAggregations () {
                const query = filterToQuery(
                    this.$store.state.view.data_filters.values
                );
                this.$store.dispatch('overview_fetch', query);
            },
        }

    }

    class IndicatorsGroupingSchema {

        constructor (groups) {
            this.indicators = [];
            this.groups = Object.keys(groups);
            this.grouped_indicators = groups;

            this.groups.forEach(
                group_name => this.indicators.splice(
                    this.indicators.length, 0, ...groups[group_name]
                )
            );
        }

        clone () {
            const groups = Object.assign({}, this.grouped_indicators);
            Object.keys(groups).forEach(group => groups[group] = groups[group].slice(0));
            return new IndicatorsGroupingSchema(groups);
        }

        isEmpty () {
            return this.indicators.length === 0;
        }

        selectInPlace (selection) {
            this.indicators = selection;
            this.groups.forEach(group => {
                const items = this.grouped_indicators[group].filter(i => selection.includes(i));
                if (items.length === 0) {
                    delete this.grouped_indicators[group];
                } else {
                    this.grouped_indicators[group] = items;
                }
            });
            this.groups = Object.keys(this.grouped_indicators);
        }

        sortInPlace (modification, indicators_instance) {
            const {indicators, groups} = indicators_instance.summary(this);

            Object
                .keys(groups)
                .forEach(group => {
                    group = this.grouped_indicators[group];
                    group.sort(
                        (a, b) => modification * (indicators[a] - indicators[b])
                    );
                });

            this.groups.sort(
                (a, b) => modification * (groups[a] - groups[b])
            );
        }

    }

    class Indicators {

        constructor (data) {
            this.indicators = data;
        }

        summary (schema) {
            const groups = schema.groups.reduce(
                (acc, name) => {
                    acc[name] = Indicators.sumGroup(
                        this.indicators,
                        schema.grouped_indicators[name]
                    );
                    return acc;
                },
                {}
            );
            return {
                indicators: this.indicators,
                groups: groups,
                total: Indicators.sumGroup(
                    groups,
                    schema.groups
                )
            }
        }

        static mergeGroup (data_list, indicator_names) {
            if (data_list.length === 1) {
                return new Indicators(data_list[0]);
            }

            const result = {};

            indicator_names.forEach(name => {
                const sum = data_list.reduce(
                    (acc, item) => acc + item[name],
                    0
                );
                result[name] = sum / data_list.length;
            });

            return new Indicators(result);
        }

        static sumGroup (data, items) {
            let value = 0;
            items.forEach(name => value += data[name]);
            return value / items.length;
        }

    }

    function addToGroup (acc, group, item) {
        const arr = acc[group];
        if (arr === undefined) {
            acc[group] = [ item ];

        } else {
            arr.push(item);
        }
    }

</script>
