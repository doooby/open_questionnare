<template>
    <v-card>

        <v-card-text>
            <v-form
             lazy-validation
             @keyup.native.enter="doLogin">

                <v-text-field
                 v-model="login"
                 :label="$t('models.user.login')"
                 :disabled="processing"/>

                <v-text-field
                 v-model="password"
                 type="password"
                 :label="$t('models.user.password')"
                 :disabled="processing"/>

            </v-form>

            <v-alert
             v-if="error_message"
             :value="true"
             type="error">
                <div
                 class="ma-2">
                    {{error_message}}
                </div>
            </v-alert>
        </v-card-text>

        <v-card-actions>
            <v-spacer/>
            <v-btn
             flat
             @click="hide"
             v-t="'actions.cancel'"/>
            <v-btn
             color="primary"
             @click="doLogin"
             :disabled="processing"
             v-t="'toolbar.login'"/>
        </v-card-actions>
    </v-card>
</template>

<script>
import { mapActions } from 'vuex';
import { apiPost } from '../../actions';

export default {

    data () {
        return {
            login: '',
            password: '',
            processing: false,
            error_message: null
        };
    },

    props: ['hide'],

    methods: {
        ...mapActions({
            loggedIn: 'login_user',
            notifyChange: 'set_notification'
        }),

        async doLogin () {
            this.processing = true;

            const result = await apiPost(
                'login',
                {
                    login: this.login,
                    password: this.password,
                    locale: this.$i18n.locale
                }
            );
            this.processing = false;

            if (result.fail) {
                this.error_message = result.reasons[0];
            } else {
                this.loggedIn(result.user);
                this.notifyChange(result.message);
                this.hide();
            }
        }
    }

};
</script>
