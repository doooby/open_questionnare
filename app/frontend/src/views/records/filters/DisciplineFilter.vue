<template>
    <div
     class="-content">
        <multi-select
         size="lg"
         :value="value"
         :items="disciplines"
         @change="change"/>
    </div>
</template>

<script>
    import { fromBaseFilter } from './filter_prototype';
    import MultiSelect from './inputs/MultiSelect';
    import sortBy from 'lodash/sortBy';

    export default fromBaseFilter('discipline', {

        components: {MultiSelect},

        computed: {
            disciplines () {
                const list = FORM_DEFINITION.fields.getOptionsListFor(
                    'class_discipline',
                    {}
                );
                const locales = FORM_DEFINITION.locales[this.$i18n.locale]
                    .q.opts[list.name];
                const options = list.getKeys().map(key => ({
                    value: key,
                    text: locales[key]
                }));
                return sortBy(options, 'text');
            }
        }

    });
</script>
