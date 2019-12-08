import { buildLocales } from './locales';
import { Fields } from './fields';

export default class Questionnaire {

    constructor (version, fields) {
        this.version = version;
        this.fields = fields;
        this.locales = {};
    }

    importLocales (source, languages) {
        this.locales = buildLocales(source.slice(1), languages);
    }

    setFieldsChangeHandlers (settings) {
        Object.keys(settings).forEach(name => {
            const field = this.fields.index[name];
            field.on_change = settings[name];
        });
    }

    setFieldsConditionals (settings) {
        Object.keys(settings).forEach(name => {
            const field = this.fields.index[name];
            field.condition = settings[name];
        });
    }

    serializeAttributes (attrs) {
        return Fields.normalizeValues(
            attrs, this.fields.index, Fields.TYPE_SERIALIZERS
        );
    }

    parseAttributes (attrs) {
        return Fields.normalizeValues(
            attrs, this.fields.index, Fields.TYPE_PARSERS
        );
    }

    updateAttribute (attrs, name, new_value) {
        const field = this.fields.index[name];
        if (!field) return attrs;

        const new_attrs = {
            ...attrs,
            [name] : new_value
        };
        if (field.on_change) {
            field.on_change(new_attrs, attrs[name]);
        }
        return  new_attrs;
    }

}
