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

    buildOptions (csv, custom) {
        if (this.options !== undefined) return;
        this.options = new SelectFieldOptions(this, csv, custom);
    }

    setFieldsChangeHandlers (fields) {
        for (const name in fields) {
            const field = this.index[name];
            field.on_change = fields[name];
        }
    }

    setFieldsConditionals (fields) {
        for (const name in fields) {
            const field = this.index[name];
            field.condition = fields[name];
        }
    }

    getOptionsListFor (field_name, attrs, ...args) {
        const field = this.index[field_name];
        return this.options.getList(field, attrs, ...args);
    }

    getOptionText (field_name, attributes, lang, translate) {
        const field = this.index[field_name];
        return this.options.getTextFor(field, attributes, lang, translate);
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
            if (!field) {
                delete attrs.name;
                continue;
            }
            const normalizer = normalizers[field.type];
            if (normalizer) attrs[name] = normalizer(attrs[name]);
        }
        return attrs;
    }

}

Fields.TYPE_CONTROL = {
    string: 'text',
    integer: 'integer',
    number: 'number',
    timestamp: null,
    gps: 'gps',
    bool: 'yesno'
};

Fields.KNOWN_TYPES = Object.keys(Fields.TYPE_CONTROL);

Fields.TYPE_PARSERS = {
    timestamp: value => new Date(value),
};

Fields.TYPE_SERIALIZERS = {
    timestamp: value => Number(value),
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
            this
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

// options:
//   control,
//   conditional,
//   select, filteredSelect, noTranslateOptions
function buildControl (field, options) {
    const def = {
        type: Fields.TYPE_CONTROL[field.type]
    };

    if (options.select !== undefined) {
        def.control = 'select';
        controlApplyOptions(field, options.select, def);
        def.filtered = options.filteredSelect !== undefined;
        def.no_translate = options.noTranslateOptions !== undefined;
    }

    if (options.control !== undefined) {
        def.control = options.control;
    }

    if (!def.type) {
        throw `cannot build control for field ${field.name} (no type for ${field.type})`;
    }

    if (options.conditional !== undefined) {
        def.conditional = options.conditional === null ?
            field.name :
            options.conditional;
    }

    return def;
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


function validateControlValue (value, field) {
    switch (field.type) {
        case 'integer':
        case 'number':
            return validateControlValue.isNumber(value);

        case 'string':
            return validateControlValue.isNonEmptyString(value);

        // case 'bool':
        //     return true;
        //
        // case 'gps':
        //     if (typeof value !== 'object') return false;
        //     return (
        //         validateControlValue.isNumber(value.n) &&
        //         validateControlValue.isNumber(value.t)
        //     );

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


class SelectFieldOptions {

    constructor (fields, csv, custom) {
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

    getList (field, attrs, ...args) {
        const list = new OptionsList(field, this.index);
        list.build(attrs, ...args);
        return list;
    }

    getTextFor (field, attributes, lang, translate) {
        const value = attributes[field.name];
        const control = field.control;
        const options = this.index[control.options];
        if (typeof options === 'object' && options.getOne) {
            const item = options.getOne(attributes, value);
            if (!item) return '';
            return control.no_translate ?
                item.optionKey() :
                item.optionText(lang, translate);
        } else {
            return control.no_translate ?
                value :
                translate(value);
        }
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
        const {options, options_name, no_translate} = field.control;
        this.name = options_name;
        this.options = options_index[options];
        this.no_translate = no_translate;

        this.items = null;
    }

    build (attrs, ...args) {
        if (this.options === undefined) this.options = [];

        const options = this.options;
        if (typeof options === 'object' && options.getAll) {
            this.items = options.getAll(attrs, ...args);
        }
    }

    getKeyAt (index) {
        if (this.items) {
            const item = this.items[index];
            if (item) return item.optionKey();
        } else {
            return this.options[index];
        }
    }

    getKeys () {
        if (this.items) return this.items.map(item => item.optionKey());
        return this.options;
    }

    getPairs (lang, translate) {
        if (this.items) {
            return this.no_translate ?
                this.items.map(item => {
                    const key = item.optionKey();
                    return [key, key];
                }) :
                this.items.map(item =>
                    [item.optionKey(), item.optionText(lang, translate)]
                );

        } else {
            return this.no_translate ?
                this.options.map(key =>
                    [key, key]
                ) :
                this.options.map(key =>
                    [key, translate(key)]
                );

        }
    }

    count () {
        return this.items ? this.items.length : this.options.length;
    }

}
