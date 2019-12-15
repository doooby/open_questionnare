<template>
    <div
     class="control">
        <span
        class="v-label theme--light">
        {{selectedText}}
        </span>

        <v-btn
         v-if="context.indicatorsSchema"
         color="accent"
         small
         v-t="'views.overview.controls.indicators.change'"
         flat
         @click="openModal"
         class="ma-0"/>
    </div>
</template>

<script>
    import IndicatorsSelectionModal from './IndicatorsSelectionModal';

    export default {

        props: ['control', 'value', 't-prefix', 'context'],

        computed: {
            selectedText () {
                if (!this.value) return;
                if (this.value === 'all') return this.$t('controls.select.selected_all');
                return `${this.value.length} ${this.$t('controls.select.selected')}`;
            }
        },

        methods: {

            openModal () {
                this.$dialogHolder.open(
                    IndicatorsSelectionModal,
                    {
                        schema: this.context.indicatorsSchema,
                        'default-value' : this.value,
                        onSet: (new_value) => this.$emit('input', new_value)
                    }
                )
            }

        }

    }
</script>
