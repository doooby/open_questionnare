<template>
    <div
     class="-content">
        <multi-select
         :value="value"
         :items="collectors"
         @change="change"/>
    </div>
</template>

<script>
    import { fromBaseFilter } from './filter_prototype';
    import { apiGet } from '../../../actions';
    import MultiSelect from './inputs/MultiSelect';

    export default fromBaseFilter('collector', {

        data () {
            return {
                collectors: []
            };
        },

        components: {MultiSelect},

        beforeMount () {
            (async function (component) {
                const result = await apiGet('users/collectors');
                if (!result.fail) {
                    component.collectors = result.users
                        .map(({id, name}) =>({
                            value: id,
                            text: name
                        }));
                }
            }(this));
        }

    });
</script>
