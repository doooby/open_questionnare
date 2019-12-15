<template>
    <div
     :class="buildClassName()">
        <v-menu
         v-model="expanded"
         :close-on-content-click="false">
            <template
             v-slot:activator="{on}">
                <v-text-field
                 box
                 append-icon="mdi-calendar"
                 hide-details
                 single-line
                 v-model="text_field_value"
                 @change="dateChanged"
                 @click:append="on.click($event)"/>
            </template>
            <v-date-picker
             no-title
             scrollable
             color="primary"
             @input="datePicked"/>
        </v-menu>
    </div>
</template>

<script>
    import { dayjs, date_formats, format_date } from '../../../../config/i18n';
    import { sizeClassName } from './helpers';

    export default {

        props: {
            value: null,
            size: {
                type: String,
                required: false
            }
        },

        data () {
            return {
                expanded: false,
                text_field_value: format_date(
                    this.value,
                    this.$i18n.locale,
                    'short'
                )
            }
        },

        computed: {
            date_text () {
                return format_date(
                    this.value,
                    this.$i18n.locale,
                    'short'
                );
            }
        },

        watch: {
            date_text (value) {
                this.text_field_value = value;
            }
        },

        methods: {
            buildClassName () {
                return sizeClassName(this.size);
            },

            datePicked (picker_value) {
                this.expanded = false;
                this.$emit('change', picker_value);
            },

            dateChanged (input_value) {
                let day = dayjs(input_value);

                if (day.isValid()) {
                    this.$emit('change', day.format(date_formats._def));

                } else {
                    this.text_field_value = this.date_text;

                }
            }
        }
    }

</script>
