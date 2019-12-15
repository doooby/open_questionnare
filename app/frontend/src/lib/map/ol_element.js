import '@webcomponents/webcomponentsjs/webcomponents-bundle.js';
import ol_css_url from '!!file-loader?name=static/css/ol.[hash:8].css!extract-loader!css-loader!ol/ol.css';

export default class OLElement extends HTMLElement {
    constructor() {
        super();

        const shadow = this.attachShadow({mode: 'open'});

        const css_link = document.createElement('LINK');
        css_link.rel = 'stylesheet';
        css_link.type = 'text/css';
        css_link.href = ol_css_url;
        shadow.appendChild(css_link);

        const container_div = document.createElement('DIV');
        container_div.id = 'ol-map';
        shadow.appendChild(container_div);
        this._container = container_div;
    }

    connectedCallback () {
        // if (this.isConnected) {} // it may be no longer connected

        this.dispatchEvent(new CustomEvent(
            'connect',
            { detail: this._container }
        ));
    }
}

window.customElements.define('open-layer-map', OLElement);
