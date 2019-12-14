import Chance from 'NODE_MODULES/chance/chance';

export const chance = new Chance();

const TIMESTAMPS_SPAN = 8640000000; // 100 days = 100 * 24 * 60 * 60 * 1000

export function generateRandomAttrs(questionnaire, options={}) {
    const { attrs, type_generators, generators, filter } = options;

    let fields = questionnaire.fields.list;
    if (filter) fields = fields.filter(filter);
    const randomized_fields = randomizeArray(fields);
    const randomAttrs = attrs ? attrs : {};

    for (const field of randomized_fields) {
        const generator = generatorFor(field, generators, type_generators);
        const value = generator(randomAttrs, field, questionnaire);
        if (value !== null) randomAttrs[field.name] = value;
    }

    randomAttrs['version'] = questionnaire.version;
    return randomAttrs;
}

function generatorFor (field, generators, type_generators) {
    const generator = (
        (generators && generators[field.name]) ||
        META_GENERATORS[field.name] ||
        getControlGenerator(field) ||
        (type_generators && type_generators[field.type]) ||
        TYPE_GENERATORS[field.type]
    );
    if (!generator) throw `no generator for field ${field.name}[${field.type}]`;
    return generator;
}

function randomizeArray (array) {
    return array.slice(0).sort(() => Math.random() - 0.5);
}

function getControlGenerator (field) {
    if (!field.control) return;
    const { control } = field.control;
    switch (control) {
        case 'text-long': return FIELD_GENERATORS.sentence;
        case 'select': return FIELD_GENERATORS.select;
    }
}

const FIELD_GENERATORS = {
    sentence: () => chance.sentence(),
    select: (attrs, field, questionnaire) => {
        const options = questionnaire.fields.options.getList(field, attrs);
        const index = Math.floor(Math.random() * options.count());
        return options.getKeyAt(index);
    },
};

const META_GENERATORS = {
    record_id: () => String(Math.floor(Math.random() * 1000000000)),

    user: () => 'collector',

    created_at: () => {
        let created_at = Number(new Date());

        created_at += Math.floor(Math.random() * TIMESTAMPS_SPAN) - (TIMESTAMPS_SPAN / 2);
        return created_at;
    },

    updated_at: ({ created_at }) => {
        if (!created_at) return null;
        return created_at + Math.floor(Math.random() * TIMESTAMPS_SPAN / 10);
    },

    finalized_at: ({created_at, updated_at}) => {
        if (!created_at) return null;
        const last_mod = updated_at ? updated_at : created_at;
        return last_mod + (Math.random() > 0.5 ?
                0 :
                Math.floor(Math.random() * TIMESTAMPS_SPAN / 100)
        );
    }
};

const TYPE_GENERATORS = {
    string: () => chance.word(),

    integer: () => Math.floor(Math.random() * 100),

    number: () => Math.random() * 100,

    yesno: () => Math.random() > 0.5,

    gps: (function () {
        const min =     { lat: -90, lon: -180 };
        const max = { lat:  90, lon:  180 };

        return function () {
            return {
                t: chance.floating({min: min.lat, max: max.lat}),
                n: chance.floating({min: min.lon, max: max.lon})
            };
        };
    }()),
};
