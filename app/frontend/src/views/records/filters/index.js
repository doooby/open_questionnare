const filters = require.context(
    __dirname,
    false,
    /Filter.vue$/
);

export const filters_index = filters.keys().reduce(
    (acc, file) => {
        const module = filters(file).default;
        acc[module._EMA_filter_name] = module;
        return acc;
    },
    {}
);

export const filters_names = Object.keys(filters_index);

export function filtersDefaultState (current_state) {
    let { data_filters } = current_state.view;

    if (!data_filters) {
        const values = {};
        for (const name of filters_names) { values[name] = null; }

        data_filters = {
            shown: [ 'location' ],
            values: {
                ...values,
                location: filterInitValue('location')
            }
        }
    }

    return  data_filters;
}

export function filterInitValue (name) {
    const init_value = filters_index[name]._EMA_filter_init_value;
    return init_value ? init_value() : null;
}

export function filterToQuery (values) {
    return filters_names.reduce(
        (memo, filter_name) => {
            const value = values[filter_name];
            if (value) memo[filter_name] = value;
            return memo;
        },
        {}
    );
}
