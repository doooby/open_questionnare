import Vue from 'vue';
import 'vuetify/src/stylus/app.styl';
import '@mdi/font/css/materialdesignicons.min.css';

import Vuetify, {
    VApp,
    VAlert,
    VBtn,
    VCard,
    VCardActions,
    VCardText,
    VCardTitle,
    VCheckbox,
    VChip,
    VContainer,
    VContent,
    VDataTable,
    VDatePicker,
    VDialog,
    VDivider,
    VExpansionPanel,
    VExpansionPanelContent,
    VFlex,
    VForm,
    VIcon,
    VImg,
    VLayout,
    VList,
    VListTile,
    VListTileAction,
    VListTileContent,
    VListTileTitle,
    VMenu,
    VProgressLinear,
    VRadio,
    VRadioGroup,
    VSelect,
    VSnackbar,
    VSpacer,
    VTextField,
    VToolbar,
    VToolbarItems,
    VToolbarTitle,
} from 'vuetify/lib'
import { Ripple } from 'vuetify/lib/directives'

Vue.config.productionTip = false;

Vue.use(Vuetify, {
    components: {
        VApp,
        VAlert,
        VBtn,
        VCard,
        VCardActions,
        VCardText,
        VCardTitle,
        VCheckbox,
        VChip,
        VContainer,
        VContent,
        VDataTable,
        VDatePicker,
        VDialog,
        VDivider,
        VExpansionPanel,
        VExpansionPanelContent,
        VFlex,
        VForm,
        VIcon,
        VImg,
        VLayout,
        VList,
        VListTile,
        VListTileAction,
        VListTileContent,
        VListTileTitle,
        VMenu,
        VProgressLinear,
        VRadio,
        VRadioGroup,
        VSelect,
        VSnackbar,
        VSpacer,
        VTextField,
        VToolbar,
        VToolbarItems,
        VToolbarTitle,
    },
    directives: {
        Ripple
    },
    theme: {
        primary: '#e64614',
        secondary: '#e67800',
        accent: '#009682',

        error: '#e60028',
        info: '#009682'
    },
    iconfont: 'mdi'
});