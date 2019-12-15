<template>
    <div
     :class="buildClassName()">
        <v-select
         :value="value"
         box
         hide-details
         single-line
         clearable
         :items="items || []"
         :disabled="items === null"
         @change="$emit('change', $event)">

            <template
             v-slot:prepend-item>
                <v-list-tile>
                    <v-text-field
                     hide-details
                     solo
                     prepend-icon="mdi-filter-outline"
                     single-line
                     v-model="search"/>
                </v-list-tile>

                <v-divider
                 class="mt-2"/>
            </template>

        </v-select>
    </div>
</template>

<script>
    import { sizeClassName } from './helpers';
    import { throttle } from '../../../../actions';

    export default {
        props: {
            items: Array,
            value: null,
            size: {
                type: String,
                default: 'md'
            }
        },

        data () {
            return {
                search: null,
                searcher: throttle(
                    input => this.$emit('search', input),
                    400
                )
            };
        },

        watch: {
            value (value) {
                if (value === null) this.search = null;
            },

            items (items) {
                if (items === null) this.search = null;
            },

            search (value) {
                if (this.items !== null) this.searcher(value);
            }
        },

        methods: {
            buildClassName() {
                return sizeClassName(this.size);
            }
        }
    };
</script>
