<template>
    <div
     class="-content">
        <div
         class="v-input v-input--label">
            {{labels.province}}:
        </div>
        <select-with-search
         :items="provinces"
         :value="value.province"
         @change="changeProp('p', $event)"
         @search="searchProp('p', $event)"/>

        <div
         class="v-input v-input--label">
            {{labels.municipality}}:
        </div>
        <select-with-search
         :items="municipalities"
         :value="value.municipality"
         @change="changeProp('m', $event)"
         @search="searchProp('m', $event)"/>

        <div
         class="v-input v-input--label">
            {{labels.commune}}:
        </div>
        <select-with-search
         :items="communes"
         :value="value.commune"
         @change="changeProp('c', $event)"
         @search="searchProp('c', $event)"/>
    </div>
</template>

<script>
    import { fromBaseFilter } from './filter_prototype';
    import SelectWithSearch from './inputs/SelectWithSearch';

    export default fromBaseFilter('location', {
        _EMA_filter_init_value () {
            return {
                province: null,
                municipality: null,
                commune: null
            }
        },

        components: {SelectWithSearch},

        data () {
            return {
                provinces: this.searchProvinces(),
                municipalities: null,
                communes: null
            }
        },

        computed: {
            labels () {
                const locales = FORM_DEFINITION.locales[this.$i18n.locale].q.attrs;
                return {
                    province: locales['school_province'],
                    municipality: locales['school_municipality'],
                    commune: locales['school_commune'],
                }
            }
        },

        methods: {
            changeProp (prop, new_val) {
                if (!new_val) new_val = null;
                switch (prop) {
                    case 'p':
                        this.change({
                            province: new_val,
                            municipality: null,
                            commune: null
                        });
                        this.municipalities = new_val && this.searchMunicipalities();
                        this.communes = null;
                        break;

                    case 'm':
                        this.change({
                            ...this.value,
                            municipality: new_val,
                            commune: null
                        });
                        this.communes = new_val && this.searchCommunes();
                        break;

                    case 'c':
                        this.change({
                            ...this.value,
                            commune: new_val
                        });
                        break;
                }
            },

            searchProp (prop, search) {
                switch (prop) {
                    case 'p':
                        this.provinces = this.searchProvinces(search);
                        break;

                    case 'm':
                        this.municipalities = this.searchMunicipalities(search);
                        break;

                    case 'c':
                        this.communes = this.searchCommunes(search);
                        break;
                }
            },

            searchProvinces (text='') {
                const list = FORM_DEFINITION.fields.getOptionsListFor(
                    'school_province',
                    {},
                    text
                );
                return regions_to_options(list.items);
            },

            searchMunicipalities (text='') {
                const list = FORM_DEFINITION.fields.getOptionsListFor(
                    'school_municipality',
                    {
                        school_province: this.value.province
                    },
                    text
                );
                return regions_to_options(list.items);
            },

            searchCommunes (text='') {
                const list = FORM_DEFINITION.fields.getOptionsListFor(
                    'school_commune',
                    {
                        school_province: this.value.province,
                        school_municipality: this.value.municipality
                    },
                    text
                );
                return regions_to_options(list.items);
            }
        }

    });

    function regions_to_options (items) {
        return items.map(reg => Object.freeze({
            value: reg.code,
            text: reg.name
        }));
    }
</script>
