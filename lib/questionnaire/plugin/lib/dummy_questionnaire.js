import { Fields } from 'QUESTIONNAIRE_SRC/fields';
import Questionnaire from 'QUESTIONNAIRE_SRC/questionnaire';
import fields_csv from './app/dummy_questionnaire/v0_fields.csv';
import locales_csv from './app/dummy_questionnaire/v0_locales.csv';

const VERSION = 0;

const DUMMY = new Questionnaire(
    VERSION,
    Fields.parseFieldsFromCsv(fields_csv, VERSION)
);

DUMMY.importLocales(locales_csv, ['en']);

export default DUMMY;
