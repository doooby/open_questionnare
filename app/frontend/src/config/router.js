import Vue from 'vue';
import Router from 'vue-router';
import store from './store';

import Home from '../views/Home';
import Records from '../views/Records';
import Overview from '../views/Overview';
import Users from '../views/Users';

Vue.use(Router);

export function createRouter () {
    const router = new Router({
        mode: 'history',
        base: process.env.BASE_URL,
        routes: [
            {
                path: '/',
                name: 'home',
                component: Home
            },

            {
                path: '/pages/records',
                name: 'records',
                component: Records,
                meta: { assert_login: {} }
            },

            {
                path: '/pages/overview',
                name: 'overview',
                component: Overview,
                meta: { assert_login: {} }
            },

            {
                path: '/pages/users',
                name: 'users',
                component: Users,
                meta: { assert_login: { admin: true } }
            }
        ]
    });

    router.afterEach((to) => {
        store.dispatch('change_route', to.name);
    });

    router.beforeEach((to, from, next) => {
        const login_assertion = to.meta.assert_login;
        if (login_assertion) {
            const user = store.state.user;
            let fail_reason = null;

            if (!user) {
                fail_reason = 'authn';
            } else if (login_assertion.admin && !user.admin) {
                fail_reason = 'authr';
            }

            if (fail_reason) {
                next({ name: 'home' });
                return;
            }
        }

        next();
    });

    return router;
}
