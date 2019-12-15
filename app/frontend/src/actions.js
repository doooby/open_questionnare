import { i18n } from './config/i18n';
import { saveAs } from 'file-saver';

const ACTION_THROTTLE = 1000;

// ripple effect is 300ms
const FINISH_RIPPLE_THROTTLE = 400;

export const actions = {

    change_route ({ commit, state }, route) {
        commit('ROUTE_CHANGED', {
            route,
            view: defaultState(route, state)
        });
    },

    login_user ({ commit }, user) {
        if (user && user.login) {
            commit('USER_LOGGED_IN', {
                login: user.login,
                admin: user.admin,
                locale: user.language
            });
        }
    },

    set_notification ({ commit }, text) {
        commit('SHOW_NOTIFICATION', text);
    },

    // USERS

    async fetch_users ({ commit }) {
        commit('FETCH_START_USERS');

        const result = await apiGet('users');
        if (result.fail) {
            commit('FETCH_END_USERS');
        } else {
            commit('FETCH_END_USERS', result.users)
        }
    },

    // RECORDS

    records_fetch: (function () {
        async function fetch (commit, query) {
            const result = await apiPost(
                `records/browse_fetch`,
                query
            );

            if (result.fail) {
                commit('RECORDS_FETCH_END');
            } else {
                commit('RECORDS_FETCH_END', result)
            }
        }

        const throttled_fetch = throttle(
            fetch,
            ACTION_THROTTLE,
            true
        );

        return function ({ commit }, query) {
            commit('RECORDS_FETCH_START');

            throttled_fetch(commit, query);
        };
    }()),

    overview_fetch: (function () {
        async function fetch (commit, query) {
            const result = await apiPost(
                `records/aggregations_fetch`,
                query
            );

            if (result.fail) {
                commit('OVERVIEW_FETCH_END');
            } else {
                commit('OVERVIEW_FETCH_END', result)
            }
        }

        const throttled_fetch = throttle(
            fetch,
            ACTION_THROTTLE,
            true
        );

        return function ({ commit }, query) {
            commit('OVERVIEW_FETCH_START');

            throttled_fetch(commit, query);
        };
    }()),

};

const DEFAULT_STATE_SETTERS = {};

export function setDefaultStateSetter (name, fn) {
    DEFAULT_STATE_SETTERS[name] = fn;
}

export function defaultState (component, current_state) {
    const fn = DEFAULT_STATE_SETTERS[component];
    return fn ? fn(current_state) : {};
}

export function createDelayer (minTime) {
    const start = new Date();
    return function (action) {
        const delay = minTime - (new Date() - start);
        if (delay > 0) setTimeout(action, delay);
        else action();
    };
}

export function apiGet (path) {
    return fetchPagesApi(path);
}

export function apiPost (path, data = {}) {
    data.locale = i18n.locale;
    return fetchPagesApi(path, {
        method: 'POST',
        body: JSON.stringify(data)
    });
}

export async function downloadCSVFromApi (path, post_data = {}) {
    let data;
    const options = {
        credentials: 'include',
        headers: {'Content-type': 'application/json'},
        method: 'POST',
        body: JSON.stringify(post_data)
    };

    try {
        const response = await fetch('/app/' + path, options);
        data = await response.blob();

        const file_name_find = (/filename="(.+)"/).exec(
            safeGetHeader(response.headers, 'Content-Disposition')
        );
        const file_name = file_name_find ?
            file_name_find[1] :
            'ema_download.csv';

        saveAs(data, file_name);

    } catch (e) {
        console.error(e);
    }
}

async function fetchPagesApi (path, options = {}) {
    let data;
    const delayer = createDelayer(FINISH_RIPPLE_THROTTLE);

    options.credentials = 'include';
    options.headers = {
        'Content-Type': 'application/json',
        ...(options.headers || {})
    };

    try {
        const response = await fetch('/app/' + path, options);
        data = await response.json();
    } catch (e) {
        console.error(e);
        data = {
            fail: true,
            error: e,
            reasons: [e.message]
        };
    }

    if (data.fail && !data.reasons) {
        data.reasons = [
            i18n.t(`processing.${data.reason || 'server_down'}`)
        ];
    }

    const delay = new Promise(delayer);
    await delay;

    return data;
}

function safeGetHeader (headers, name) {
    if (headers.has(name)) return headers.get(name);
    else return '';
}


export function throttle (callback, time, immediate) {
    var timeout, call_at_end, context, args;

    return function () {
        context = this;
        args = arguments;

        // throttling block
        if (timeout) {
            call_at_end = true;
            return;
        }

        // throttler - fire only if there was event in the mean-time
        var timeout_f = function () {
            timeout = null;
            if (call_at_end) {
                call_at_end = false;
                timeout = setTimeout(timeout_f, time);
                callback.apply(context, args);
            }
        };

        call_at_end = true;
        if (immediate) timeout_f();
        else timeout = setTimeout(timeout_f, time);
    };
}

export function snooze (time) {
    return new Promise(resolve => setTimeout(resolve, time));
}
