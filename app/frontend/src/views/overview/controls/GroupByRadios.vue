<template>
    <div
     class="control">
        <v-radio-group
         row
         hide-details
         :value="value"
         @change="$emit('input', $event)">
            <v-radio
             v-for="option in options"
             :key="option.value"
             :value="option.value"
             :label="option.text"/>
        </v-radio-group>
    </div>
</template>

<script>
    export default {

        props: ['control', 'value'],

        computed: {

            options () {
                return [
                    {
                        value: '1',
                        text: this.$t('records.geography.prov')
                    },
                    {
                        value: '2',
                        text: this.$t('records.geography.mun')
                    },
                    {
                        value: '3',
                        text: this.$t('records.geography.com')
                    }
                ];
            }
        }
    }
</script>
