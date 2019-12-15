<template>
    <div
     :class="buildClassName()">
        <v-text-field
         :value="value"
         box
         hide-details
         single-line
         @change="$emit('change', $event)"/>
    </div>
</template>

<script>
    import { sizeClassName } from './helpers';

    export default {
        props: {
            value: null,
            size: {
                type: String,
                default: 'md'
            }
        },

        methods: {
            buildClassName() {
                return sizeClassName(this.size);
            }
        }
    };
</script>
