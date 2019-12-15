<template>
    <div
     :class="buildClassName()">
        <v-select
         :value="value || []"
         :loading="!items"
         box
         hide-details
         single-line
         :items="items"
         multiple
         @change="$emit('change', $event)">

            <template
             v-slot:prepend-item>
                <v-list-tile
                 ripple
                 @click="toggleAll">
                    <v-list-tile-action>
                        <v-icon
                         :color="all_icon_color">
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
             v-if="index === 0 && value.length === 1">
                {{item.text}}
            </span>
                <span
                 v-if="index === 0 && value.length > 1"
                 class="grey--text">
                {{value.length}} {{$t('controls.select.selected')}}
            </span>
            </template>

        </v-select>
    </div>
</template>

<script>
    import { sizeClassName } from './helpers';

    export default {
        props: {
            items: Array,
            value: null,
            size: {
                type: String,
                default: 'md'
            }
        },

        computed: {
            all_icon () {
                const selected = this.value ? this.value.length : 0;
                if (selected === this.items.length) return 'mdi-close-box';
                if (selected > 0) return 'mdi-minus-box';
                return 'mdi-checkbox-blank-outline';
            },

            all_icon_color () {
                if (this.value && this.value.length > 0) return 'primary darken-4';
            }
        },

        methods: {
            buildClassName() {
                return sizeClassName(this.size);
            },

            toggleAll () {
                this.$nextTick(() => {
                    if (this.value && this.value.length === this.items.length) {
                        this.$emit('change', []);

                    } else {
                        this.$emit('change', this.items.map(item => item.value));

                    }
                });
            }
        }
    }
</script>
