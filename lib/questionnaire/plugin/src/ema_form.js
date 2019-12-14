import { Fields } from 'QUESTIONNAIRE_SRC/fields';
import Questionnaire from 'QUESTIONNAIRE_SRC/questionnaire';

import fields_csv from './ema_form/v4_fields.csv';
import locales_csv from './ema_form/v4_locales.csv';

import geography from './geography/geography';

const VERSION = 0;

////////////////////////////////////////////////////////////////////////////////
// FIELDS
const FIELDS = Fields.parseFieldsFromCsv(fields_csv, VERSION);

FIELDS.buildOptions(null, {
    provinces: {
        getAll (attrs, search) {
            return geography.provinces(search);
        },
        getOne (_, value) {
            return geography.getRegion(value);
        }
    },
    municipalities: {
        getAll ({ school_province }, search) {
            return geography.municipalities(school_province, search);
        },
        getOne ({ school_province }, value) {
            return geography.getRegion(`${school_province}.${value}`);
        }
    },
    communes: {
        getAll ({ school_province, school_municipality }, search) {
            return geography.communes(school_province, school_municipality, search);
        },
        getOne ({ school_province, school_municipality }, value) {
            return geography.getRegion(`${school_province}.${school_municipality}.${value}`);
        }
    },
});

FIELDS.setFieldsChangeHandlers({
    school_province (attrs) {
        attrs['school_municipality'] = null;
        attrs['school_commune'] = null;
    },
    school_municipality (attrs) {
        attrs['school_commune'] = null;
    },
    teacher_pedag (attrs, current) {
        if (!current) attrs['teacher_pedag_val'] = null;
    },
});

FIELDS.setFieldsConditionals({
    teacher_pedag_val (attrs) {
        return attrs['teacher_pedag'] === true;
    },
});

////////////////////////////////////////////////////////////////////////////////
// QUESTIONNAIRE
const EMA_FORM = new Questionnaire(VERSION, FIELDS);
export default EMA_FORM;

EMA_FORM.importLocales(locales_csv, ['en', 'pt']);
