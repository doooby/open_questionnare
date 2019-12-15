<template>
    <v-expansion-panel-content>
        <v-layout
         slot="header"
         align-center>
            <v-flex
             xs4
             class="headline">
                {{user.login}}
                <v-chip
                 small
                 v-if="!user.enabled">
                    {{$t('views.users.labels.disabled')}}
                </v-chip>
            </v-flex>
            <v-flex
             xs4>
                <span
                 v-t="'models.user.role'"
                 class="subheading"/>:
                {{user.role}}
            </v-flex>
            <v-flex
             xs4>
                <span
                 v-t="'views.users.labels.last_authn'"
                 class="subheading"/>:
                {{user.last_authn}}
            </v-flex>
        </v-layout>
        <v-card>
            <v-card-actions>

                <v-btn
                 flat
                 color="secondary"
                 v-t="'views.users.labels.change_pass'"
                 @click="openPasswordChangeForm"/>

                <v-btn
                 flat
                 color="secondary"
                 @click="toggleDisabled(user.enabled)"
                 :disabled="btn_enable_disable_processing">
                    {{$t(`views.users.labels.${user.enabled ? 'dis' : 'en'}able`)}}
                </v-btn>

                <v-spacer/>

                <v-btn
                 color="error"
                 v-t="'views.users.labels.delete_user'"
                 @click="openConfirmDelete"/>

            </v-card-actions>
        </v-card>
    </v-expansion-panel-content>
</template>

<script>
import { mapActions } from 'vuex';
import { apiPost } from '../../actions';

import ChangePasswordForm from './ChangePasswordForm';
import ConfirmDeleteUser from './ConfirmDeleteUser';

export default {

    data () {
        return {
            btn_enable_disable_processing: false
        };
    },

    props: ['user'],

    methods: {
        ...mapActions({
            notifyChange: 'set_notification'
        }),

        openPasswordChangeForm () {
            this.$dialogHolder.open(
                ChangePasswordForm,
                {user: this.user}
            );
        },

        async toggleDisabled (disable) {
            this.btn_enable_disable_processing = true;

            const result = await apiPost(
                `users/${this.user.id}/${disable ? 'dis' : 'en'}able`
            );
            this.btn_enable_disable_processing = false;

            if (result.ok) {
                this.notifyChange(result.message);
                this.updateUser(result.user);
            }
        },

        updateUser (user) {
            this.$store.commit('UPDATE_USER', user);
        },

        openConfirmDelete () {
            this.$dialogHolder.open(
                ChangePasswordForm,
                {user: this.user}
            );
        }
    }

};
</script>
