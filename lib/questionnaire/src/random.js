import Chance from 'NODE_MODULES/chance/chance';
import { Field } from './fields';
import meta_fields_src from '../meta_fields.csv';

export const chance = new Chance();

const META_FIELDS = meta_fields_src.map(line => new Field(...line));

export function generateAttrs(fields, generators) {
    const attrs = {};
    fillAttrsForMeta(attrs, generators, fields.version);
    fillAttrsForControls(attrs, generators, fields);
    return attrs;
}

const TIMESTAMPS_SPAN = 8640000000; // 100 days = 100 * 24 * 60 * 60 * 1000
const metaFieldsGenerators = {
    record_id: () => String(Math.floor(Math.random() * 1000000000)),

    user: () => 'collector',

    created_at: () => {
        let created_at = Number(new Date());

        created_at += Math.floor(Math.random() * TIMESTAMPS_SPAN) - (TIMESTAMPS_SPAN / 2);
        return created_at;
    },

    updated_at: ({created_at}) => {
        return created_at + Math.floor(Math.random() * TIMESTAMPS_SPAN / 10);
    },

    finalized_at: ({created_at, updated_at}) => {
        const last_mod = updated_at ? updated_at : created_at;
        return last_mod + (Math.random() > 0.5 ?
                0 :
                Math.floor(Math.random() * TIMESTAMPS_SPAN / 100)
        );
    }
};

export function fillAttrsForMeta(attrs, generators, version) {
    generators = {
        ...metaFieldsGenerators,
        version: () => version,
        ...generators
    };

    META_FIELDS.forEach(field =>{
        attrs[field.name] = randomMetaValue(field, attrs, generators);
    });
}

export function fillAttrsForControls (attrs, generators, fields) {
    fields.list.forEach(field => {
        if (field.control && field.shouldBeFilled(attrs)) {
            attrs[field.name] = randomControlValue(field, attrs, fields, generators);
        }
    });
}

export const genericGenerators = {
    text: () => chance.word(),
    'text-long': () => chance.sentence(),
    number: () => Math.floor(Math.random() * 100),
    yesno: () => Math.random() > 0.5,

    gps: (function () {
        // try to be it in Angola
        const top_left = {lon: 9.520455, lat: -5.657680};
        const bottom_right = {lon: 23.475781, lat: -17.847797};

        const lon_add = top_left.lon;
        const lon_max = bottom_right.lon - top_left.lon;

        const lat_add = bottom_right.lat;
        const lat_max = top_left.lat - bottom_right.lat;

        return function () {
            return {
                t: chance.floating({min: 0, max: lat_max}) + lat_add,
                n: chance.floating({min: 0, max: lon_max}) + lon_add
            };
        };
    }()),

    select (field, attrs, fields) {
        const options = fields.options
            .forField(field, attrs, '')
            .getKeys();

        const index = Math.floor(Math.random() * options.length);
        return options[index];
    }
};

function randomMetaValue (field, attrs, generators) {
    if (field.canBeEmpty && Math.random() > 0.6) return null;

    const generator = generators[field.name];
    return generator ? generator(attrs) : null;
}

function randomControlValue (field, attrs, fields, generators) {
    if (field.canBeEmpty && Math.random() > 0.6) return null;

    const specific = generators[field.name];
    if (specific) return specific(attrs);

    const generic = genericGenerators[field.control.type];
    if (generic) {
        return generic(field, attrs, fields);
    }

    return null;
}
