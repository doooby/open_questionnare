<template>
    <v-card>

        <v-card-title>
            <span
             class="headline">
                {{$t('toolbar.language_modal')}}
            </span>
        </v-card-title>

        <v-card-text>
            <v-radio-group
             :value="$i18n.locale"
             :disabled="disabled"
             @change="switchLanguage">
                <v-radio
                 v-for="lang in languages"
                 :key="lang.locale"
                 :value="lang.locale"
                 :label="lang.name"/>
            </v-radio-group>
        </v-card-text>

        <v-card-actions>
            <v-spacer/>
            <v-btn
             flat
             @click="hide"
             v-t="'actions.close'"/>
        </v-card-actions>
    </v-card>
</template>

<script>
import { apiPost } from '../../actions';
import { setLocale } from '../../config/i18n';

export default {

    data () {
        return {
            disabled: false,
            languages: Object.keys(this.$i18n.messages)
                .map(locale => ({
                    locale,
                    name: this.$i18n.t('language', locale)
                }))
        };
    },

    props: ['hide'],

    methods: {
        switchLanguage (locale) {
            setLocale(locale);
            this.saveLanguage();
        },

        async saveLanguage () {
            this.disabled = true;

            await apiPost(
                'save_language'
            );
            
            this.disabled = false;
        }
    }

};
</script>
