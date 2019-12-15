<template>
    <v-card>

        <v-card-title>
            <span
             class="headline">
                {{$t('views.users.modals.pass.headline')}}
                {{user.login}}
            </span>
        </v-card-title>

        <v-card-text>
            <v-form
             lazy-validation
             @keyup.native.enter="setPassword">

                <v-text-field
                 v-model="password"
                 type="password"
                 :label="$t('models.user.password')"
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
             @click="setPassword"
             :disabled="processing"
             v-t="'actions.set'"/>
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
            password: '',
            processing: false,
            errors: null
        };
    },

    components: {
        FormErrorMessages
    },

    props: ['hide', 'user'],

    methods: {
        ...mapActions({
            notifyChange: 'set_notification'
        }),

        async setPassword () {
            this.processing = true;

            const result = await apiPost(
                `users/${this.user.id}/change_password`,
                { password: this.password }
            );
            this.processing = false;

            if (result.fail) {
                this.errors = result.reasons;
            } else {
                this.hide();
                this.notifyChange(result.message);
            }
        }
    }

};
</script>
