import Vue from 'vue';
import uuid from 'uuid/v4';

const holder_data = Vue.observable({
    shown: false,
    list: []
});

const holder = {
    open (component, props={}) {
        const dialog = {
            id: uuid(),
            component
        };

        props['hide'] = () => hideDialog(dialog);
        dialog.data = {
            props: props
        };

        holder_data.shown = true;
        holder_data.list.splice(0, 0, dialog);
    },

    hide () {
        if (holder_data.list.length > 0) hideDialog(holder_data.list[0]);
    }
};

function hideDialog (dialog) {
    const index1 = holder_data.list.indexOf(dialog);
    if (index1 === -1) return;

    // only the last is actually shown
    // therefore ignore for others
    if (index1 === 0) holder_data.shown = false;

    // set timeout to remove it later.
    // this is the whole reason: vuetify button has a "ripple" effect,
    // that will fail if the nodes are gone immediately
    setTimeout(
        () => {
            const index2 = holder_data.list.indexOf(dialog);
            if (index2 !== -1) holder_data.list.splice(index2, 1);
        },
        1000
    );
}

Vue.use({
    install (vue) {
        vue.prototype.$dialogHolder = holder;
    }
});

export const DialogHolder = {
    render (h) {
        return h(
            'div',

            {
                attrs: {
                    'data-dialog-holder': true
                }
            },

            holder_data.list.map((dialog, i) => h(
                'v-dialog',
                {
                    key: dialog.id,
                    attrs: {
                        'max-width': '600px'
                    },
                    props: {
                        value: (i === 0 && holder_data.shown),
                        scrollable: true
                    },
                    on: {
                        input: dialog.data.props.hide
                    }
                },
                [
                    h(
                        dialog.component,
                        {...dialog.data}
                    )
                ]
            ))
        );
    }
};
