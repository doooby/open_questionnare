<template>
    <div
     class="control">
        <v-select
         :value="value"
         box
         hide-details
         single-line
         :items="options"
         multiple
         color="accent"
         @change="$emit('input', $event)">

            <template
             v-slot:prepend-item>
                <v-list-tile
                 ripple
                 @click="toggleAll">
                    <v-list-tile-action>
                        <v-icon
                         color="accent">
                            {{all_icon}}
                        </v-icon>
                    </v-list-tile-action>
                    <v-list-tile-content>
                        <v-list-tile-title
                         v-t="'controls.select.select_all'"/>
                    </v-list-tile-content>
                </v-list-tile>

                <v-divider
                 class="mt-2"/>
            </template>

            <template
             v-slot:selection="{item, index}">
                <span
                 v-if="index === 0">
                    {{selectionLabel(item)}}
                </span>
            </template>

        </v-select>
    </div>
</template>

<script>
    export default {

        props: ['control', 'value', 't-prefix', 'context'],

        computed: {

            options () {
                const {allRegions} = this.context;
                if (allRegions.length === 0) return [];

                return allRegions
                    .map(region => ({
                        value: region.full_code,
                        text: region.name,
                        text_to_sort: region.name.toLowerCase()
                    }))
                    .sort((a, b) => {
                        a = a.text_to_sort;
                        b = b.text_to_sort;
                        if (a < b) return -1;
                        if (a > b) return 1;
                        return 0;
                    });
            },

            all_icon () {
                return iconTypeFor(this.value, this.options);
            },

        },

        methods: {
            selectionLabel (item) {
                const selected_count = this.value.length;
                if (selected_count === 1) return item.text;
                if (selected_count > 1) {
                    if (selected_count === this.options.length)
                        return this.$t('controls.select.selected_all');
                    else return `${selected_count} ${this.$t('controls.select.selected')}`;

                }
            },

            toggleAll () {
                const new_value = this.value.length === this.options.length ?
                    [] :
                    this.options.map(opt => opt.value);

                this.$emit(
                    'input',
                    new_value
                );
            }
        }

    }

    function iconTypeFor (selected, options) {
        if (selected.length === options.length) return 'mdi-checkbox-marked';
        if (selected.length > 0) return 'mdi-minus-box';
        return 'mdi-checkbox-blank-outline';
    }
</script>
