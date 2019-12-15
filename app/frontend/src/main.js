// configuration
import { createRouter } from './config/router';
import store from './config/store';
import { i18n } from './config/i18n';
import './config/vuetify';
import './config/dialog_holder';

// lib
import './lib/map/ol_element';

// app
import Vue from 'vue';
import App from './App.vue';
import './styles/app.scss';

// init & beyond
(async function () {
    // query for user metadata
    const response = await fetch('/app/touch', {
        method: 'POST',
        credentials: 'include',
        headers: { 'Content-Type': 'application/json' }
    });
    const data = await response.json().catch(() => {
        throw "Couldn't reach server for app/touch.";
    });

    // init store
    store.dispatch('login_user', data.user || null);

    // maybe irrelevant but hey, rather few ms slower
    // then deal with JS nonsenses
    await Vue.nextTick();

    // mount Vue App
    new Vue({
        router: createRouter(),
        store,
        i18n,
        render: h => h(App)
    }).$mount('#app');
}());

// dynamically put favico
const favico = document.createElement('LINK');
favico.rel = 'icon';
favico.href = require('PLUGIN_SRC/assets/favico.png');
document.head.appendChild(favico);
