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

        props: ['control', 'value', 't-prefix'],

        computed: {

            options () {
                return [
                    {
                        value: 'desc',
                        text: this.$t(`${this.tPrefix}.desc`)
                    },
                    {
                        value: 'asc',
                        text: this.$t(`${this.tPrefix}.asc`)
                    }
                ];
            }
        }
    }
</script>
