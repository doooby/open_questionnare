<template>
    <div>

        <div
         class="mt-4 mb-4 display-1">
            {{$t('views.overview.numbers.total')}} :
            <span
             :style="totalData.css"
             class="pa-2">
                {{totalData.value}} - {{totalData.text}}
            </span>
        </div>

        <div
         class="aggrs-table list-with-lines">
            <div
             v-for="group in tableData">
                <div
                 class="d-flex headline -header">
                    <div
                     class="f0 -num"
                     :style="group.css">
                        {{group.value}}
                    </div>
                    <div>
                        {{group.text}}
                    </div>
                </div>
                <div
                 class="-detail-listing">
                    <div
                     v-for="field in group.fields"
                     class="d-flex f-align-center">
                        <div
                         class="f0 -num"
                         :style="field.css">
                            {{field.value}}
                        </div>
                        <div>
                            {{field.text}}
                        </div>
                    </div>
                </div>
            </div>
        </div>

    </div>
</template>

<script>
    import * as indicators_lib from './indicators';

    export default {
        props: ['indicators', 'schema'],

        computed: {
            summary () {
                return this.indicators.summary(this.schema);
            },

            tBase () {
                return FORM_DEFINITION.locales[this.$i18n.locale];
            },

            totalData () {
                const value = this.summary.total;
                return {
                    value: this.formatNumber(value),
                    css: { backgroundColor: indicators_lib.color(value) },
                    text: this.$t(`records.indicators.${indicators_lib.grade(value)}`)
                }
            },

            tableData () {
                return this.schema.groups.map(group_name => {
                    const group_text = this.tBase.groups[group_name].text;
                    const group_value = this.summary.groups[group_name];

                    const fields = this.schema.grouped_indicators[group_name].map(name => {
                        const value = this.summary.indicators[name];
                        const text = this.tBase.attrs[name];

                        return {
                            text,
                            value: this.formatNumber(value),
                            css: (indicators_lib.isBad(value) ?
                                { backgroundColor: indicators_lib.color(value) }:
                                null)
                        };
                    });

                    return {
                        text: group_text,
                        value: this.formatNumber(group_value),
                        css: { backgroundColor: indicators_lib.color(group_value) },
                        fields
                    };
                });
            }
        },

        methods: {
            formatNumber (value) {
                return value.toFixed(2);
            }
        }

    }
</script>
