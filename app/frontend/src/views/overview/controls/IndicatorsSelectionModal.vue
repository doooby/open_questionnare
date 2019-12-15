<template>
    <v-card>

        <v-card-title>
            <span
             class="headline">
                {{$t('views.overview.controls.indicators.modal.title')}}
            </span>
        </v-card-title>

        <v-card-text>
            <v-list>

                <v-list-tile
                 ripple
                 @click="toggleAll">
                    <v-list-tile-action>
                        <v-icon
                         color="accent">
                            {{all_icon}}
                        </v-icon>
                    </v-list-tile-action>
                    <v-list-tile-content>
                        <v-list-tile-title
                         v-t="'controls.select.select_all'"/>
                    </v-list-tile-content>
                </v-list-tile>

                <div
                 v-for="group in groups"
                 :key="group.name">

                    <hr
                     class="mt-2 v-divider theme--light">

                    <v-list-tile
                     ripple
                     @click="toggleGroup(group)">
                        <v-list-tile-action>
                            <v-icon
                             color="accent">
                                {{group.icon}}
                            </v-icon>
                        </v-list-tile-action>
                        <v-list-tile-content>
                            <v-list-tile-title>
                                {{formLocales.groups[group.name].abbr}}
                            </v-list-tile-title>
                        </v-list-tile-content>
                    </v-list-tile>

                    <v-list-tile
                     v-for="item in group.items"
                     :key="item.name"
                     ripple
                     @click="toggleItem(item, group)">
                        <v-list-tile-action
                         class="ml-5">
                            <v-icon
                             color="accent">
                                {{checkboxIcon(item.selected)}}
                            </v-icon>
                        </v-list-tile-action>
                        <v-list-tile-content>
                            <v-list-tile-title>
                                {{formLocales.attrs[item.name]}}
                            </v-list-tile-title>
                        </v-list-tile-content>
                    </v-list-tile>

                </div>

            </v-list>
        </v-card-text>

        <v-card-actions>
            <v-spacer/>
            <v-btn
             flat
             @click="hide"
             v-t="'actions.cancel'"/>
            <v-btn
             color="accent"
             @click="setIndicators"
             v-t="'actions.set'"/>
        </v-card-actions>

    </v-card>
</template>

<script>
    export default {

        props: ['hide', 'default-value', 'schema', 'on-set'],

        data () {
            const schema = this.schema;

            if (!schema) {
                return {
                    groups: [],
                    selected: [],
                    all_icon: 'mdi-close-box',
                }
            }

            const selected = (
                this.defaultValue === 'all' ?
                    schema.indicators :
                    this.defaultValue
            ).slice(0);

            const groups = schema.groups.map(
                group => {
                    const items = schema.grouped_indicators[group]
                        .map(item => ({
                            name: item,
                            selected: selected.includes(item)
                        }));
                    const selected_in_group = items.filter(({selected}) => selected);
                    return {
                        name: group,
                        items,
                        selected: selected_in_group,
                        icon: this.groupIcon(
                            selected_in_group,
                            items
                        )
                    };
                }
            );

            return {
                groups,
                all_icon: this.groupIcon(selected, schema.indicators),
            };
        },

        computed: {
            formLocales () {
                return FORM_DEFINITION.locales[this.$i18n.locale];
            }
        },

        methods: {
            toggleAll () {
                const all_selected = merge_items(
                    this.groups.map(group => group.selected)
                );
                const to_val = all_selected.length !== this.schema.indicators.length;
                this.groups.forEach(
                    group => {
                        group.items.forEach(item => item.selected = to_val);
                        this.actualizeGroup(group, false);
                    }
                );
                this.actualizeWhole();
            },

            toggleGroup (group) {
                const to_val = group.selected.length !== group.items.length;
                group.items.forEach(item => item.selected = to_val);
                this.actualizeGroup(group);
            },

            toggleItem (item, group) {
                item.selected = !item.selected;
                this.actualizeGroup(group);
            },

            actualizeGroup (group, act_whole=true) {
                group.selected = group.items.filter(({selected}) => selected);
                group.icon = this.groupIcon(
                    group.selected,
                    group.items
                );
                if (act_whole) this.actualizeWhole();
            },

            actualizeWhole () {
                const all_selected = merge_items(
                    this.groups.map(group => group.selected)
                );
                this.all_icon = this.groupIcon(
                    all_selected,
                    this.schema.indicators
                );
            },

            setIndicators () {
                this.hide();

                const all_selected = merge_items(
                    this.groups.map(group => group.selected)
                )
                    .map(opt => opt.name);
                this.onSet(
                    all_selected.length === this.schema.indicators.length ?
                        'all' :
                        all_selected
                );
            },

            checkboxIcon (value) {
                return value ? 'mdi-checkbox-marked' : 'mdi-checkbox-blank-outline';
            },

            groupIcon (selected, options) {
                return iconTypeFor(selected, options);
            },
        }

    };

    function iconTypeFor (selected, options) {
        if (selected.length === options.length) return 'mdi-checkbox-marked';
        if (selected.length > 0) return 'mdi-minus-box';
        return 'mdi-checkbox-blank-outline';
    }

    function merge_items (groups) {
        return groups.reduce(
            (acc, items) => acc.concat(items)
        )
    }

</script>
