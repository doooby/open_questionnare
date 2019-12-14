import DUMMY from 'PLUGIN_SRC/dummy_questionnaire';
import { generateRandomAttrs } from 'QUESTIONNAIRE_SRC/random';

const attrs = generateRandomAttrs(DUMMY);

console.log(attrs);
