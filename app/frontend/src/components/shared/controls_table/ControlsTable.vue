<template>
    <table
     class="controls-table">
        <tr
         v-for="control in controls"
         :key="control.name">

            <td>
                <div
                 class="v-input mr-3">
                    {{$t(control.t(tPrefix, 'caption'))}}:
                </div>
            </td>

            <td
             class="pb-2">
                <control-item
                 :control="control"
                 :model="model"
                 :t-prefix="tPrefix"
                 :context="context"/>
            </td>

        </tr>
    </table>
</template>

<script>

    const Control = {
        functional: true,
        render (h, {props}) {
            const {control, model, tPrefix, context} = props;
            return h(
                control.component,
                {
                    props: {
                        control,
                        value: model[control.name],
                        tPrefix: `${tPrefix}.${control.name}`,
                        context
                    },
                    on: {
                        input: function (value) {
                            model[control.name] = value;
                        }
                    }
                }
            );
        }
    };

    export default {

        props: ['controls', 'model', 't-prefix', 'context'],

        components: {
            'control-item': Control
        }

    }
</script>
