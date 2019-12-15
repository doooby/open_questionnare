<template>
  <v-app>

    <app-toolbar/>

    <v-content>
      <router-view/>
    </v-content>

    <dialog-holder/>

    <v-snackbar
     v-model="notification.shown"
     right
     down>
      {{notification.message}}
    </v-snackbar>

  </v-app>
</template>

<script>
import { mapState } from 'vuex';

import {DialogHolder} from './config/dialog_holder';
import AppToolbar from './components/app_toolbar/AppToolbar';

export default {

    components: {
      AppToolbar,
      DialogHolder
    },

    computed: mapState({
        notification: state => state.notification
    })

};
</script>
