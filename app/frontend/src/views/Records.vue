<template>
    <v-container
     fluid
     class="page-records">

        <div
         class="mb-3 elevation-1 pa-2">
            <records-filters
             @apply="setPagination()">
                <template v-slot:buttons>
                    <v-btn
                     color="accent"
                     class="f1"
                     @click="downloadCSV"
                     :disabled="csv_btn_disabled">
                        <v-icon
                         left>
                            mdi-download
                        </v-icon>
                        {{$t('views.records.filters.export')}}
                    </v-btn>
                </template>
            </records-filters>
        </div>

        <v-data-table
         class="elevation-1 tab-table"
         :headers="headers"
         :items="formattedRecords"
         :total-items="view.total"
         :pagination="pagination"
         @update:pagination="setPagination"
         :rows-per-page-items="[10, 50]"
         rows-per-page-text="">

            <v-progress-linear
             slot="progress"
             color="primary"
             indeterminate/>

            <template
             slot="items"
             slot-scope="props">
                <tr>
                    <td
                     v-for="column in headers"
                     :key="column.value">
                        {{props.item[column.value]}}
                    </td>
                </tr>
            </template>

            <template
             slot="no-data">
                <v-alert
                 :value="view.fetching === 'f'"
                 type="error"
                 v-t="'processing.server_fail'"/>
                <v-alert
                 :value="view.fetching === 'n'"
                 type="info"
                 v-t="'processing.no_data'"/>
            </template>

        </v-data-table>

    </v-container>
</template>

<script>
    import { mapState } from 'vuex';
    import { setDefaultStateSetter, downloadCSVFromApi } from '../actions';

    import RecordsFilters from './records/RecordsFilters';
    import { filtersDefaultState, filterToQuery } from './records/filters/index';
    import { format_date } from '../config/i18n';

    setDefaultStateSetter('records', current_state => ({
        data_filters: filtersDefaultState(current_state),

        fetching: 'n',
        records: [],
        total: 0,
        pagination: {
            page: 1,
            rowsPerPage: 10
        }
    }));

    const skip_attrs = ['school_gps'];
    const date_attrs = [
        'uploaded_at',
        'created_at',
        'updated_at',
        'finalized_at'
    ];
    const discipline_attr = 'class_discipline';

    export default {
        name: 'records',

        components: {
            RecordsFilters,
        },

        data () {
            return {
                csv_btn_disabled: false
            };
        },

        computed: {
            ...mapState([ 'view' ]),

            headers () {
                const headers = FORM_DEFINITION
                    .localizedFieldsHeaders(this.$i18n.locale)
                    .filter(({field}) => !skip_attrs.includes(field))
                    .map(({field, text}) => ({
                        value: field,
                        text,
                        align: 'left',
                        sortable: false,
                    }));

                headers.splice(0, 0, ...(
                    ['qid', 'uploaded_at'].map(attr => ({
                        value: attr,
                        text: this.$i18n.t(`models.form.${attr}`),
                        align: 'left',
                        sortable: false
                    }))
                ));

                return headers;
            },

            pagination () {
                return this.view.pagination;
            },

            formattedRecords () {
                const locale = this.$i18n.locale;
                const disciplines = FORM_DEFINITION
                    .locales[locale].q.opts.class_discipline;

                return this.view.records.map(record => {
                    record = {...record};

                    date_attrs.forEach(attr => {
                        record[attr] = format_date(
                            record[attr],
                            locale
                        );
                    });

                    record[discipline_attr] = disciplines[record[discipline_attr]];

                    return record;
                });
            }
        },

        watch: {
            pagination () {
                this.fetchRecords();
            }
        },

        methods: {
            setPagination (value) {
                if (!value) {
                    value = {
                        page: 1,
                        rowsPerPage: this.view.pagination.rowsPerPage
                    };
                }

                this.$store.commit('RECORDS_CHANGE_PAGINATION', value);
            },

            fetchRecords () {
                const state = this.$store.state.view;
                const {page, rowsPerPage} = state.pagination;

                this.$store.dispatch('records_fetch', {
                    ...filterToQuery(state.data_filters.values),
                    page,
                    per_page: rowsPerPage
                });
            },

            async downloadCSV () {
                this.csv_btn_disabled = true;
                setTimeout(
                    () => { this.csv_btn_disabled = false; },
                    1000
                );

                downloadCSVFromApi(
                    `records/download_csv`,
                    filterToQuery(
                        this.$store.state.view.data_filters.values
                    )
                );

            }
        }
    };

</script>
