import { buildLocales } from './locales';

export default class Questionnaire {

    constructor (version, fields) {
        this.version = version;
        this.fields = fields;
    }

    importLocales (source, languages) {
        this.locales = buildLocales(source.slice(1), languages);
    }

}
