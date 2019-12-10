import { sanitizeCsvRow, arrayUniq } from './utils';
import meta_fields_src from '../meta_fields.csv';

export class Fields {

    constructor (fields_list, version) {
        this.list = fields_list;
        Object.freeze(this.list);

        this.index = fields_list.reduce(
            (memo, field) => {
                memo[field.name] = field;
                return memo;
            },
            {}
        );
        Object.freeze(this.index);

        this.groups = fields_list.reduce(
            (memo, field) => {
                let group = memo[field.group];
                if (!group) {
                    group = [];
                    memo[field.group] = group;
                }
                group.push(field);
                return memo;
            },
            {}
        );
        Object.freeze(this.groups);

        this.version = version;
    }

    buildOptions (settings={}) {
        if (this.options !== undefined) return;
        this.options = new SelectFieldOptions(this, settings);
    }

    getOptionsListFor (field_name, attrs, ...args) {
        const field = this.index[field_name];
        return this.options.forField(field, attrs, ...args);
    }

    static parseFieldsFromCsv (lines, ...args) {
        const fields_list = meta_fields_src.map(line => new Field(...line));

        const invalid_types = fields_list.filter( f =>
            !Fields.KNOWN_TYPES.includes(f.type)
        );
        if (invalid_types.length !== 0) {
            const map = (list, f) => list.map(f).join(',');
            console.log(
                `invalid_types: ${map(invalid_types, f => f.name + '=' + f.type)}`
            );
            const types = arrayUniq( invalid_types.map(t => t.type) );
            throw `unknown types [${types.join(',')}]`;
        }

        lines.slice(1).forEach(line => {
            if (line[0]) {
                line = sanitizeCsvRow(line, 4);
                fields_list.push(new Field(...line));
            }
        });

        return new Fields(fields_list, ...args);
    }

    static normalizeValues (attrs, fields_index, normalizers) {
        attrs = {...attrs};
        for (const name in attrs) {
            if (!attrs.hasOwnProperty(name)) continue;
            const field = fields_index[name];
            if (!field) delete attrs.name;
            const normalizer = normalizers[name];
            if (normalizer) attrs[name] = normalizers(attrs[name]);
        }
    }

}

Fields.TYPE_CONTROL = {
    string: 'text',
    integer: 'integer',
    number: 'number',
    timestamp: null,
    // gps: null,
    // bool: 'yesno'
};

Fields.KNOWN_TYPES = Object.keys(Fields.TYPE_CONTROL);

Fields.TYPE_PARSERS = {
    date: value => new Date(value),
};

Fields.TYPE_SERIALIZERS = {
    date: value => Number(value),
};

export class Field {

    constructor (name, group, type, options) {
        this.name = name;
        this.group = group;
        this.type = type;
        options = parseFieldOptions(options);
        if (group !== 'meta') {
            this.control = buildControl(this, options);
        }
        this.canBeEmpty = options['optional'] === null;
    }

    shouldBeFilled (attrs) {
        return this.condition ?
            this.condition(attrs) :
            true;
    }

    mustBeFilled (attrs) {
        return this.canBeEmpty ?
            false :
            this.shouldBeFilled(attrs);
    }

    isValueValid (attrs) {
        if (!this.mustBeFilled(attrs)) return true;
        return validateControlValue(
            attrs[this.name],
            this.control.type
        );
    }

}

function parseFieldOptions (options_raw) {
    const options = {};
    if (options_raw) {
        options_raw.split('&').forEach(opt => {
            const [key, value] = opt.split('=');
            options[key] = value || null;
        });
    }
    return options;
}

function buildControl (field, options) {
    const {control, select, conditional} = options;
    const control_definition = {
        type: control || Fields.TYPE_CONTROL[field.type]
    };

    if (select !== undefined) {
        switch (field.type) {
            case 'string':
                control_definition.control = 'select-text';
                controlApplyOptions(field, select, control_definition);
                break;
            case 'integer':
            case 'number':
                control_definition.control = 'select-number';
                controlApplyOptions(field, select, control_definition);
                break;
        }
    }

    if (!control_definition.type) {
        throw `cannot build control for field ${field.name} (no type for ${field.type})`;
    }

    if (conditional !== undefined) {
        control_definition.conditional = conditional === null ?
            field.name :
            conditional;
    }

    return control_definition;
}

function controlApplyOptions (field, select_value, control) {
    if (select_value === null) {
        control.options = field.name;
        control.options_name = field.name;

    } else {
        control.options = select_value;
        control.options_name = select_value[0] === '[' ?
            field.name :
            select_value;
    }
}

class SelectFieldOptions {

    constructor (fields, {csv, custom}) {
        this.index = {};

        if (csv) SelectFieldOptions.fillFromCsv(this.index, csv);

        SelectFieldOptions.parseShorthands(this.index, fields);

        if (custom) {
            this.index = {
                ...this.index,
                ...custom
            };
        }

        Object.freeze(this.index);
    }

    forField (field, attrs, ...args) {
        const list = new OptionsList(field, this.index);
        list.build(attrs, ...args);
        return list;
    }

    static fillFromCsv (options_index, lines) {
        lines.forEach(line => {
            if (line[0]) {
                const [name, value] = sanitizeCsvRow(line, 2);
                let option_list = options_index[name];
                if (option_list === undefined) {
                    option_list = [];
                    options_index[name] = option_list;
                }
                option_list.push(value);
            }
        });
    }

    static parseShorthands (options_index, fields) {
        fields.list.forEach( field => {
            if (!field.control) return;
            const { options } = field.control;
            if (!options || options[0] !== '[') return;

            let opts = options_index[options];
            if (opts === undefined) {
                opts = SelectFieldOptions.parseShorthand(options);
                options_index[options] = opts;
            }
        });
    }

    static parseShorthand (options) {
        const list = [];
        const parts = options
            .slice(1, options.length - 1)
            .split(':');

        for (let i=0, part; i<parts.length; i+=1) {
            part = parts[i];

            const range = part.match(/^(\d+)-(\d+)$/);
            if (range !== null) {
                const start = Number(range[1]);
                const end = Number(range[2]);
                if (start > end) {
                    for (let n=start; n>=end; n-=1) list.push(n);
                } else {
                    for (let n=start; n<=end; n+=1) list.push(n);
                }

            } else {
                list.push(part);

            }
        }
        Object.freeze(list);
        return list;
    }

}



class OptionsList {

    constructor (field, options_index) {
        const {options, options_name} = field.control;
        this.name = options_name;
        this.keys = options_index[options];
        this.items = null;
    }

    build (attrs, ...args) {
        if (typeof this.keys === 'function') {
            this.items = this.keys(attrs, ...args);
        }
    }

    getKeys () {
        if (this.items) return this.items.map(i => i.optionKey());
        return this.keys;
    }

    getPairs (translate) {
        if (this.items) {
            return this.items.map(item => [
                item.optionKey(), item.optionText(translate)
            ]);

        } else {
            return this.keys.map(key => [
               key, (translate ? translate(key) : key)
            ]);

        }
    }

}

function validateControlValue (value, control_type) {
    switch (control_type) {
        case 'number':
            return validateControlValue.isNumber(value);

        case 'text':
        case 'text-select':
        case 'text-long':
            return validateControlValue.isNonEmptyString(value);

        case 'select':
            return validateControlValue.isNonEmptyString(value) ||
                validateControlValue.isNumber(value);

        case 'yesno':
            return true;

        case 'gps':
            if (typeof value !== 'object') return false;
            return (
                validateControlValue.isNumber(value.n) &&
                validateControlValue.isNumber(value.t)
            );

        default:
            return false;
    }
}

validateControlValue.isNumber = function (value) {
    return typeof value === 'number' && !isNaN(value);
};

validateControlValue.isNonEmptyString = function (value) {
    return typeof value === 'string' && value.length > 0;
};
