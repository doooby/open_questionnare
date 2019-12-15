<template>
    <v-toolbar-title>
        <v-layout
         align-center>

            <v-flex
             v-if="user">
            <span
             class="caption white--text">
            {{$t('toolbar.logged_in', {login: user.login})}}
            </span>
            </v-flex>
            <v-flex
             v-else>
                <v-btn
                 small
                 v-t="'toolbar.login'"
                 @click="showLoginModal"/>
            </v-flex>

            <v-flex>
                <v-menu
                 offset-y
                 left>
                    <v-btn
                     slot="activator"
                     :icon="true">
                        <v-icon
                         color="white">
                            mdi-settings
                        </v-icon>
                    </v-btn>

                    <v-list>

                        <v-list-tile
                         v-if="user"
                         :disabled="logout_processing"
                         @click="doLogout">
                            <v-list-tile-title
                             v-t="'toolbar.logout'"/>
                        </v-list-tile>

                        <v-list-tile
                         @click="showLanguageModal">
                            <v-list-tile-title
                             v-t="'toolbar.language'"/>
                        </v-list-tile>

                    </v-list>
                </v-menu>
            </v-flex>

        </v-layout>

    </v-toolbar-title>
</template>

<script>
import { mapState, mapActions } from 'vuex';
import { apiPost } from '../../actions';

import LoginModal from './LoginModal';
import LanguageModal from './LanguageModal';

export default {

    data () {
        return {
            logout_processing: false,
        };
    },

    computed: mapState({
        user: state => state.user
    }),

    methods: {
        ...mapActions({
            notifyLogout: 'set_notification'
        }),

        showLoginModal () {
            this.$dialogHolder.open(LoginModal);
        },

        showLanguageModal () {
            this.$dialogHolder.open(LanguageModal);
        },

        loggedOut () {
            this.$store.commit('USER_LOGGED_OUT');
        },

        async doLogout () {
            this.logout_processing = true;

            const result = await apiPost(
                'logout',
                {}
            );
            this.logout_processing = false;

            if (result.ok) {
                this.loggedOut();
                this.$router.push({ name: 'home' });
                if (result.message) this.notifyLogout(result.message);
            }
        }

    }

};
</script>
