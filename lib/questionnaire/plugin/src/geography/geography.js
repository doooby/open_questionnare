import src from './src_map.csv';
import { createTextMatcher } from 'QUESTIONNAIRE_SRC/utils';

class Region {

    constructor (level, code, name) {
        this.level = level;
        this.code = code;
        this.full_code = null;
        this.name = name;
        this.parent = null;
        this.children = null;
    }

    listOfChildren () {
        return Object.keys(this.children).map(code => this.children[code]);
    }

    filterChildren (text) {
        const list = this.listOfChildren();
        if (text && text.length > 0) {
            const matcher = createTextMatcher(text);
            return list.filter(reg => matcher(reg.name));
        } else {
            return list;
        }
    }

    optionKey () {
        return this.code;
    }

    fullCodeAtLevel (level) {
        level = Number(level);
        if (this.level === level) return this.full_code;
        if (level < this.level) return this.parent.fullCodeAtLevel(level);
    }

    fullRegionName () {
        switch (this.level) {
            case 1: return this.name;
            case 2: return `${this.parent.name}, ${this.name}`;
            case 3: return `${this.parent.parent.name}, ${this.parent.name}, ${this.name}`;
        }
    }

}

const index = src.slice(1).reduce(
    (memo, row) => {
        const [l1, l1_name, l2, l2_name, l3, l3_name] = row;
        if (!l1) return memo;

        let province = memo[l1];
        if (!province) {
            province = new Region(1, l1, l1_name);
            province.children = {};
            province.full_code = l1;
            memo[l1] = province;
        }

        let municipality = province.children[l2];
        if (!municipality) {
            municipality = new Region(2, l2, l2_name);
            municipality.parent = province;
            municipality.full_code = `${l1}.${l2}`;
            municipality.children = {};
            province.children[l2] = municipality;
        }

        let commune = municipality.children[l3];
        if (!commune) {
            commune = new Region(3, l3, l3_name);
            commune.parent = municipality;
            commune.full_code = `${l1}.${l2}.${l3}`;
            municipality.children[l3] = commune;
        }

        return memo;
    },
    {}
);

const geography = {
    index: index,

    listOfProvinces () {
        return Object.keys(index).map(code => index[code]);
    },

    getRegion (key) {
        let [prov, mun, com] = key.split('.');
        prov = index[prov];
        if (!mun) return prov;
        mun = prov.children[mun];
        if (!com) return mun;
        return mun.children[com];
    },

    provinces(text) {
        const list = geography.listOfProvinces();
        if (text && text.length > 0) {
            const matcher = createTextMatcher(text);
            return list.filter(reg => matcher(reg.name));
        } else {
            return list;
        }
    },

    municipalities(province, text) {
        province = index[province];
        if (!province) return [];
        return province.filterChildren(text);
    },

    communes(province, municipality, text) {
        province = index[province];
        if (!province) return [];
        municipality = province.children[municipality];
        if (!municipality) return [];
        return municipality.filterChildren(text);
    },

};

Object.freeze(index);
geography.listOfProvinces().forEach(province => {
    Object.freeze(province);
    Object.freeze(province.children);
    province.listOfChildren().forEach(municipality => {
        Object.freeze(municipality);
        Object.freeze(municipality.children);
        municipality.listOfChildren().forEach(commune => {
            Object.freeze(commune);
        })
    });
});

export default geography;
