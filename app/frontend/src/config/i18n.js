import Vue from 'vue';
import VueI18n from 'vue-i18n';

import messages from './locales/builder';

import dayjs from 'dayjs';
import 'dayjs/locale/en';
import 'dayjs/locale/pt';

Vue.use(VueI18n);

const STORE_KEY_LANGUAGE = 'EMA-locale';

export const i18n = new VueI18n({
    messages,

    locale: (function () {
        const locale = window.localStorage.getItem(STORE_KEY_LANGUAGE) ||
            window.navigator.language;
        return Object.keys(messages).includes(locale) ?
            locale :
            'en';
    }())
});

dayjs.locale(i18n.locale);

export function setLocale (locale) {
    window.localStorage.setItem(STORE_KEY_LANGUAGE, locale);
    i18n.locale = locale;
    dayjs.locale(locale);
}

export { dayjs };

export const date_formats = {
    _def: 'YYYY-MM-DD',
    en: {
        full: 'MMMM D, YYYY',
        short: 'YYYY-MM-DD'
    },
    pt: {
        full: 'D [de] MMMM [de] YYYY',
        short: 'DD/MM/YYYY'
    }
};

export function format_date (value, locale, format='full') {
    if (value) {
        format = date_formats[locale][format];
        return dayjs(value).format(format);
    }
}
