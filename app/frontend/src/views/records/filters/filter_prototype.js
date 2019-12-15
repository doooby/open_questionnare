import { mapState } from 'vuex';

export function fromBaseFilter (name, definition) {
    merge(
        definition,
        'computed',
        mapState({
            value: state => state.view.data_filters.values[name]
        })
    );

    merge(
        definition,
        'methods',
        {
            change (value) {
                this.$store.commit('RECORDS_SET_FILTER_VALUE', {
                    filter_name: name,
                    value: value
                });
            }
        }
    );

    definition._EMA_filter_name = name;
    return definition;
}

function merge (object, attribute, ...to_merge) {
    object[attribute] = Object.assign(
        object[attribute] || {},
        ...to_merge
    );
}