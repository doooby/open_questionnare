<template>
    <v-toolbar
     app
     flat
     class="primary">

        <v-toolbar-title>
            <router-link
             to="/">
                <v-img
                 :src="logo"
                 width="140px"/>
            </router-link>
        </v-toolbar-title>

        <v-toolbar-items
         class="hidden-sm-and-down">

            <v-btn
             v-if="user"
             to="/pages/records"
             class="white--text"
             flat>
                {{$t('toolbar.pages.records')}}
            </v-btn>

            <v-btn
             v-if="user"
             to="/pages/overview"
             class="white--text"
             flat>
                {{$t('toolbar.pages.overview')}}
            </v-btn>

            <v-btn
             v-if="isAdmin"
             to="/pages/users"
             class="white--text"
             flat>
                {{$t('toolbar.pages.users')}}
            </v-btn>

        </v-toolbar-items>

        <v-spacer/>

        <app-toolbar-menu/>

    </v-toolbar>
</template>

<script>
import { mapState } from 'vuex';

import AppToolbarMenu from './AppToolbarMenu';
import EMA_LOGO from 'PLUGIN_SRC/assets/ema.png';

export default {

    data () {
        return {
            logo: EMA_LOGO
        };
    },

    components: {
        AppToolbarMenu
    },

    computed: {
        ...mapState({
            user: state => state.user
        }),
        isAdmin () { return this.user && this.user.admin; }
    }

};
</script>
