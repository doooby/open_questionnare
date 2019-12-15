import ControlsTable from './ControlsTable';

export class Control {

    constructor (name, component) {
        this.name = name;
        this.component = component;
    }

    t (prefix, sub_key) {
        return `${prefix}.${this.name}.${sub_key}`;
    }

}

export {ControlsTable};
