import Vue from 'vue';
import Vuex from 'vuex';

import { actions, defaultState } from '../actions';
import { setLocale } from './i18n';

Vue.use(Vuex);

export default new Vuex.Store({
    state: () => ({
        route: {
            current: null,
            denied: null
        },

        user: null,

        view: {},

        notification: {
            shown: false,
            message: null
        }
    }),

    actions,

    mutations: {

        ROUTE_CHANGED (state, { route, view }) {
            state.route.current = route;
            state.route.denied = null;
            state.view = view;
        },

        USER_LOGGED_IN (state, user) {
            state.user = user;
            if (user.locale) { setLocale(user.locale); }
        },

        USER_LOGGED_OUT (state) {
            state.user = null;
        },

        SHOW_NOTIFICATION (state, text) {
            if (text) {
                state.notification.shown = true;
                state.notification.message = text;
            }
        },

        LOGIN_USER (state, user) {
            state.user = user;
        },

        /// USERS page

        FETCH_START_USERS (state) {
            state.view.loading_users = 'y';
        },

        FETCH_END_USERS (state, users) {
            if (state.view.loading_users !== 'y') return;

            if (typeof users === 'object') {
                state.view.loading_users = 'n';
                state.view.users = Object.freeze(users);
            } else {
                state.view.loading_users = 'f';
                state.view.users = null;
            }
        },

        UPDATE_USER ({ view }, user) {
            if (user) {
                const index = view.users.findIndex(u => u.id === user.id);
                if (index === -1) return;

                const users = view.users.slice();
                users[index] = user;
                view.users = Object.freeze(users);
            }
        },

        /// RECORDS page

        RECORDS_ADD_FILTER ({ view }, { filter_name, init_value }) {
            const { data_filters } = view;
            if (!data_filters) return;

            if (!data_filters.shown.includes(filter_name)) {
                data_filters.shown.push(filter_name);
                data_filters.values[filter_name] = init_value === undefined ?
                    null :
                    init_value;
            }
        },

        RECORDS_REMOVE_FILTER ({ view }, filter_name) {
            const { data_filters } = view;
            if (!data_filters) return;

            const index = data_filters.shown.indexOf(filter_name);
            if (index !== -1) data_filters.shown.splice(index, 1);
            data_filters.values[filter_name] = null;
        },

        RECORDS_SET_FILTER_VALUE ({ view }, {filter_name, value}) {
            const { data_filters } = view;
            if (!data_filters) return;

            data_filters.values[filter_name] = value;
        },

        RECORDS_FETCH_START ({ view }) {
            view.fetching = 'y';
        },

        RECORDS_FETCH_END ({ view }, result) {
            if (view.fetching !== 'y') return;

            if (result) {
                const {items, total} = result;
                view.fetching = 'n';
                view.records = Object.freeze(items);
                view.total = total || 0;

            } else {
                view.fetching = 'f';
                view.records = [];
                view.total = 0;

            }
        },

        RECORDS_CHANGE_PAGINATION ({ view }, pagination) {
            view.pagination = pagination;
        },

        OVERVIEW_FETCH_START ({ view }) {
            view.fetching = 'y';
        },

        OVERVIEW_FETCH_END ({ view }, result) {
            if (view.fetching !== 'y') return;

            if (result) {
                view.fetching = 'n';
                view.data = Object.freeze(result.data);

            } else {
                view.fetching = 'f';
                view.records = null;

            }
        },

    }
});
