import { buildLocales } from './locales';
import { Fields } from './fields';

export default class Questionnaire {

    constructor (version, fields) {
        this.version = version;
        this.fields = fields;
        fields.buildOptions();
        this.locales = {};
    }

    importLocales (source, languages) {
        this.locales = buildLocales(source.slice(1), languages);
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

    getField (name) {
        const field = this.fields.index[name];
        if (!field) throw `no such field ${name}`;
        return field;
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
