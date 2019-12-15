<template>
  <div
   class="page-home">

    <v-alert
     v-if="denied_route"
     :value="denied_route"
     type="error"
     class="ma-4"
     dismissible>
      {{denied_route.message}}
    </v-alert>

    <v-container>
      <v-layout>

        <v-flex
         offset-xs3
         xs6>
          <v-img
           :src="pin_logo"
           max-height="300px"
           contain/>
        </v-flex>

      </v-layout>
      <v-layout>

        <v-flex
         offset-xs3
         xs6>
          <v-img
           :src="ema_big_logo"
           max-height="250px"
           contain/>
        </v-flex>

      </v-layout>
    </v-container>

  </div>
</template>

<script>
import { mapState } from 'vuex';

import PIN_LOGO from 'PLUGIN_SRC/assets/pin_logo.png';
import EMA_LOGO from 'PLUGIN_SRC/assets/ema_big.png';

export default {
    name: 'home',

    data () {
        return {
            pin_logo: PIN_LOGO,
            ema_big_logo: EMA_LOGO
        };
    },

    components: {},

    computed: {
        ...mapState({
            denied_route: state => state.route.denied
        })
    }
};
</script>
