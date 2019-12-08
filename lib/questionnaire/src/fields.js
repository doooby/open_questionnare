import { sanitizeCsvRow } from './utils';
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

    buildOptions (settings) {
        this.options = new SelectFieldOptions(this, settings);
    }

    getOptionsListFor (field_name, attrs, ...args) {
        const field = this.index[field_name];
        return this.options.forField(field, attrs, ...args);
    }

    static parseFieldsFromCsv (lines, ...args) {
        const fields_list = meta_fields_src.map(line => new Field(...line));

        const invalid_types = fields_list.filter(f =>
           !Fields.KNOWN_TYPES.includes(f.type)
        );
        if (invalid_types.length !== 0) {
            throw `unknown type '${f.type}' of field '${f.name}'`;
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

Fields.TYPE_TO_CONTROL = {
    string: 'text',
    integer: 'number',
    gps: 'gps',
    bool: 'yesno'
};

Fields.KNOWN_TYPES = [
    'string',
    'date',
    'integer'
];

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

const WITH_OPTIONS = ['select', 'text-select'];
function buildControl (field, options) {
    const {control, select, conditional} = options;
    const control_definition = {
        type: (
            control ||
            (select && 'select') ||
            Fields.TYPE_TO_CONTROL[field.type]
        )
    };

    if (WITH_OPTIONS.includes(control_definition.type)) {
        if (select === null) {
            control_definition.options = field.name;
            control_definition.options_name = field.name;

        } else {
            control_definition.options = select;
            control_definition.options_name = select[0] === '[' ?
                field.name :
                select;
        }
    }

    if (conditional !== undefined) {
        control_definition.conditional = conditional === null ?
            field.name :
            conditional;
    }

    return control_definition;
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
        const list = new OptionsList(field.control, this.index);
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

        function parse (options) {
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
                        for (let n=start; n>=end; n-=1) list.push(String(n));
                    } else {
                        for (let n=start; n<=end; n+=1) list.push(String(n));
                    }

                } else {
                    list.push(part);

                }
            }
            Object.freeze(list);
            return list;
        }

        fields.list.forEach(field => {
            if (!field.control) return;
            const {options} = field.control;
            if (!options || options[0] !== '[') return;

            let opt = options_index[options];
            if (opt === undefined) {
                opt = parse(options);
                options_index[options] = opt;
            }
        });
    }

}

class OptionsList {

    constructor ({options, options_name}, options_index) {
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
