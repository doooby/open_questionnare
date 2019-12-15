<template>
    <div>
        <div
         class="headline">
            {{$t('views.records.filters.header')}}:
        </div>

        <v-container
         fluid
         class="pa-0">

            <table
             class="filters-table">
                <filter-wrap
                 v-for="filter in data_filters.shown"
                 :key="filter"
                 :filter-id="filter"/>
            </table>

            <div
             class="d-flex">

                <div
                 class="f0">
                    <v-menu>
                        <template
                         v-slot:activator="{on}">
                            <v-btn
                             v-on="on"
                             flat
                             v-t="'views.records.filters.add'"
                             color="primary"
                             class="btn-slim"/>
                        </template>
                        <v-list>
                            <v-list-tile
                             v-for="item in filter_items"
                             :key="item.name"
                             :disabled="item.shown"
                             @click="addFilter(item.name)">
                                <v-list-tile-title>
                                    {{item.text}}
                                </v-list-tile-title>
                            </v-list-tile>
                        </v-list>
                    </v-menu>
                </div>

                <div></div>

                <div
                 class="f0 d-flex f-end f-no-wrap">
                    <v-btn
                     color="primary"
                     class="f1"
                     @click="$emit('apply')">
                        <v-icon
                         left>
                            mdi-database-search
                        </v-icon>
                        {{$t('views.records.filters.apply')}}
                    </v-btn>
                    <slot
                     name="buttons"/>
                </div>

            </div>

        </v-container>

    </div>
</template>

<script>
    import { mapState } from 'vuex';
    import { filters_names, filterInitValue } from './filters';
    import FilterWrap from './filters/FilterWrap';

    export default {

        components: {
            FilterWrap
        },

        computed: {
            ...mapState({
                data_filters: state => state.view.data_filters,
            }),

            filter_items () {
                return filters_names.map(name => ({
                    name,
                    text: this.$t(`views.records.filter.${name}.label`),
                    shown: this.data_filters.shown.includes(name)
                }));
            }
        },

        methods: {
            addFilter (name) {
                this.$store.commit('RECORDS_ADD_FILTER', {
                    filter_name: name,
                    init_value: filterInitValue(name)
                });
            }
        }

    }
</script>
