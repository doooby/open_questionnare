import VectorSource from 'ol/source/Vector';
import {Map, View} from 'ol';
import TileLayer from 'ol/layer/Tile';
import OSM from 'ol/source/OSM';
import VectorLayer from 'ol/layer/Vector';
import {fromLonLat} from 'ol/proj';
import Feature from 'ol/Feature';
import Point from 'ol/geom/Point';

export default class DistrictMap {

    constructor (target) {
        this.vector_source = new VectorSource();

        this.map = new Map({
            target,
            layers: [
                new TileLayer({
                    source: new OSM()
                }),
                new VectorLayer({
                    source: this.vector_source
                })
            ],
            view: new View({
                center: fromLonLat([15.746040, -12.773986]),
                zoom: 6
            })
        });
    }

    setFeatures (items) {
        this.vector_source.clear();
        this.vector_source.addFeatures(
            items.map(({location}) =>
                new Feature({
                    geometry: new Point(fromLonLat(location))
                })
            )
        );
    }

}
