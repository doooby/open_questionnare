<template>
    <v-card>

        <v-card-title>
            <span
             class="headline"
             v-t="'views.users.modals.new.headline'"/>
        </v-card-title>

        <v-card-text>
            <v-form
             lazy-validation
             @keyup.native.enter="create">

                <v-text-field
                 v-model="login"
                 :label="$t('models.user.login')"
                 :disabled="processing"/>

                <v-text-field
                 v-model="password"
                 type="password"
                 :label="$t('models.user.password')"
                 :disabled="processing"/>

                <v-select
                 v-model="role"
                 :items="roles"
                 :label="$t('models.user.role')"
                 :disabled="processing"/>

            </v-form>

            <form-error-messages
             v-if="errors"
             :messages="errors"/>
        </v-card-text>

        <v-card-actions>
            <v-spacer/>
            <v-btn
             flat
             @click="hide"
             v-t="'actions.cancel'"/>
            <v-btn
             color="primary"
             @click="create"
             :disabled="processing"
             v-t="'actions.create'"/>
        </v-card-actions>
    </v-card>
</template>

<script>
import { mapActions } from 'vuex';
import { apiPost } from '../../actions';

import FormErrorMessages from '../shared/FormErrorMessages';

export default {

    data () {
        return {
            login: '',
            password: '',
            role: '',

            roles: [
                { value: 'regular', text: 'Web Pages user' },
                { value: 'collector', text: 'Data Collector' },
                { value: 'admin', text: 'Administrator' }
            ],

            processing: false,
            errors: null
        };
    },

    components: {
        FormErrorMessages
    },

    props: ['hide'],

    methods: {
        ...mapActions({
            notifyCreation: 'set_notification',
            afterCreate: 'fetch_users'
        }),

        async create () {
            this.processing = true;

            const data = {
                login: this.login,
                password: this.password,
                role: this.role
            };

            const result = await apiPost('users', { user: data });
            this.processing = false;

            if (result.fail) {
                this.errors = result.reasons;
            } else {
                this.hide();
                this.notifyCreation(result.message);
                this.afterCreate();
            }
        }
    }

};
</script>
