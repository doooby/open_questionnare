import { Fields } from 'QUESTIONNAIRE_SRC/fields';
import Questionnaire from 'QUESTIONNAIRE_SRC/questionnaire';
import { createTextMatcher } from 'QUESTIONNAIRE_SRC/utils';

import fields_csv from './app/dummy_questionnaire/v0_fields.csv';
import locales_csv from './app/dummy_questionnaire/v0_locales.csv';

const VERSION = 0;

const fields = Fields.parseFieldsFromCsv(fields_csv, VERSION);

fields.buildOptions(null, {
    filter: {
        items: [ 'Hynku', 'Vileme', 'Jarmilo'],
        getAll (attrs, filter='') {
            // use some other already set attribute:
            // this particular example makes no sense,
            // but sometime you need to have attributes dependent on other
            // selected values
            const confidence = Number(attrs['self']);

            const matcher = createTextMatcher(filter);
            const opts = [];
            for (let i=0, item; i<3; i+=1) {
                item = this.items[i];
                if (matcher(item)) opts.push({
                    key: `${item} - ${confidence}`,
                    optionKey () { return this.key; }
                });
            }
            return opts;
        },
        getOne (key) {
            return {
                key,
                optionKey () { return this.key; }
            };
        }
    }
});

const DUMMY = new Questionnaire(VERSION, fields);
DUMMY.importLocales(locales_csv, ['en']);

globalThis.DUMMY = DUMMY;

export default DUMMY;
