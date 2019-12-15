<template>
    <v-progress-linear
     v-if="loading"
     color="primary"
     class="ma-0"
     indeterminate/>

    <v-alert
     v-else-if="loading_fail"
     value="true"
     type="error"
     v-t="'processing.server_fail'"/>

    <v-expansion-panel
     v-else>
        <users-listing-item
         v-for="user in users"
         :key="user.id"
         :user="user"/>
    </v-expansion-panel>
</template>

<script>
import { mapState } from 'vuex';

import UsersListingItem from './UsersListingItem';

export default {

    components: {
        UsersListingItem
    },

    computed: {
        ...mapState({
            loading: state => state.view.loading_users === 'y',
            loading_fail: state => state.view.loading_users === 'f',
            users: state => (state.view.users || [])
        })
    }

};
</script>
