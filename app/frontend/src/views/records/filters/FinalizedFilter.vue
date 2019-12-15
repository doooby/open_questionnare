<template>
    <div
     class="-content">
        <div
         class="v-input v-input--label"
         v-t="'views.records.filters.between'"/>
        <date-pick
         size="sm"
         :value="value.from"
         @change="changeProp('from', $event)"/>
        <date-pick
         size="sm"
         :value="value.to"
         @change="changeProp('to', $event)"/>
    </div>
</template>

<script>
    import { fromBaseFilter } from './filter_prototype';
    import DatePick from './inputs/DatePick';

    export default fromBaseFilter('finalized', {
        _EMA_filter_init_value () {
            const today = (new Date()).toISOString().slice(0, 10);
            return {
                from: today,
                to: today
            }
        },

        components: {DatePick},

        methods: {
            changeProp (prop, new_val) {
                this.change({
                    ...this.value,
                    [prop]: new_val
                });
            }
        }

    });
</script>
