import {Map, View} from 'ol';
import {Tile as TileLayer, Vector as VectorLayer} from 'ol/layer.js';
import {OSM, Vector as VectorSource} from 'ol/source';
import GeoJSON from 'ol/format/GeoJSON';
import TopoJSON from 'ol/format/TopoJSON';
import {fromLonLat} from 'ol/proj';

const layers_types = {
    tile: TileLayer,
    vector: VectorLayer
};

export default class GeoJsonMap {

    constructor (target) {
        this.ol_map = new Map({
            target,
            view: new View({
                center: fromLonLat([15.746040, -12.773986]),
                zoom: 6
            })
        });

        this.layers_index = {};

        this.defaults();
    }

    defaults () {
        this.setLayer('osm', 'tile', {
            source: new OSM()
        })
    }

    static vSourceFromGeoJson (json) {
        return new VectorSource({
            features: (new GeoJSON()).readFeatures(json)
        });
    }

    static vSourceFromTopoJson (json) {
        return new VectorSource({
            features: (new TopoJSON()).readFeatures(json)
        });
    }

    setLayer (name, layer, arg) {
        if (typeof layer === 'string') {
            const type = layers_types[layer];
            layer = new type(arg);
        }

        const layers = this.ol_map.getLayers();
        const current = this.layers_index[name];
        if (current) { layers.remove(current); }

        this.layers_index[name] = layer;
        layers.push(layer);
    }

    removeLayer (name) {
        const layer = this.layers_index[name];
        if (layer) {
            this.ol_map.getLayers().remove(layer);

            this.layers_index[name] = null;
        }
    }

}

GeoJsonMap.fromLonLat = fromLonLat;
