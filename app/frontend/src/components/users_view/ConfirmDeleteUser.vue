<template>
    <v-card>

        <v-card-text>
            <div
             class="headline"
             v-t="{path: 'views.users.modals.del.text', args: {user: user.login}}"/>
            <div
             class="mt-3"
             v-t="'views.users.modals.del.notice'"/>
        </v-card-text>

        <v-card-actions>
            <v-spacer/>
            <v-btn
             flat
             @click="hide"
             v-t="'actions.cancel'"/>
            <v-btn
             color="error"
             @click="deleteUser"
             :disabled="processing"
             v-t="'actions.destroy'"/>
        </v-card-actions>

    </v-card>
</template>

<script>
import { mapActions } from 'vuex';
import { apiPost } from '../../actions';

export default {

    data () {
        return {
            processing: false
        };
    },

    props: ['hide', 'user'],

    methods: {
        ...mapActions({
            notify: 'set_notification',
            afterCreate: 'fetch_users'
        }),

        async deleteUser () {
            this.processing = true;

            const result = await apiPost(
                `users/${this.user.id}/delete`
            );
            this.processing = false;

            if (result.ok) {
                this.notify(result.message);
                this.afterCreate();
                this.hide();
            }
        }
    }

};
</script>
