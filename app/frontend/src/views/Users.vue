<template>
    <v-container
     fluid
     class="page-users">

        <v-toolbar
         class="mb-4">
            <v-toolbar-items>

                <v-btn
                 flat
                 @click="fetchUsers">
                    <v-icon
                     large
                     left>
                        mdi-database-refresh
                    </v-icon>
                    {{$t('views.users.toolbar.sync')}}
                </v-btn>

                <v-btn
                 flat
                 @click="openNewUserForm">
                    <v-icon
                     large
                     left>
                        mdi-account-plus
                    </v-icon>
                    {{$t('views.users.toolbar.new')}}
                </v-btn>

            </v-toolbar-items>
        </v-toolbar>

        <users-listing/>

    </v-container>
</template>

<script>
import { mapActions } from 'vuex';
import { setDefaultStateSetter } from '../actions';

import UsersListing from '../components/users_view/UsersListing';
import NewUserForm from '../components/users_view/NewUserForm';

setDefaultStateSetter('users', () => ({
    loading_users: 'n',
    users: null
}));

export default {
    name: 'users',

    components: {
        UsersListing,
        NewUserForm
    },

    beforeMount () {
        this.fetchUsers();
    },

    methods: {
        ...mapActions({
            fetchUsers: 'fetch_users'
        }),

        openNewUserForm () {
            this.$dialogHolder.open(NewUserForm);
        }
    }
};
</script>
