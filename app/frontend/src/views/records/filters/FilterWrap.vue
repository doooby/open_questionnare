<template>
    <tr
    class="filter">

        <td>
            <div
             class="d-flex f0">
                    <v-checkbox
                     color="primary"
                     hide-details
                     input-value="true"
                     @change="remove"/>
                <div
                 class="f1 v-input v-input--label mr-3">
                    {{label}}:
                </div>
            </div>
        </td>

        <td>
            <filter-item
             :filter-id="filterId"/>
        </td>

    </tr>
</template>

<script>
    import { filters_index } from './index';

    const FilterItem = {
        functional: true,
        render (h, {props}) {
            const component = filters_index[props.filterId];
            return h(component || '');
        }
    };

    export default {

        props: ['filter-id'],
        components: {FilterItem},

        computed: {
            label () {
                return this.$t(`views.records.filter.${this.filterId}.label`)
            }
        },

        methods: {
            remove () {
                this.$store.commit('RECORDS_REMOVE_FILTER', this.filterId);
            }
        }

    }
</script>
