import { Elm } from "./elm/Main.elm";
import './style/index.scss';

const incident1 = require('../data/F01705150050.json');
const incident2 = require('../data/F01705150090.json');

let map = null;
let inactive_markers = [];
let active_markers = [];

const clearAllMarkers = () => {
	    // deactive all markers, return them to the pool
  active_markers.forEach(marker => {
    marker.setMap(null);
    google.maps.event.clearInstanceListeners(marker);
  });

  inactive_markers = inactive_markers.concat(active_markers);

  active_markers.length = 0;
};

const app = Elm.Main.init({
 	node: document.getElementById("root"),
 	flags: [ incident1, incident2 ]
});

app.ports.resetMap.subscribe(() => {
  if (map) {
    clearAllMarkers();
    google.maps.event.clearInstanceListeners(map);
    map = null;
  }
});

app.ports.syncMap.subscribe((opts) => {
  requestAnimationFrame(() => {
  	if (map === null) {
      map = new google.maps.Map(document.getElementById(opts.id));

      map.addListener('zoom_changed', () =>
      		app.ports.updateViewport.send({
      			center: map.getCenter(),
      			zoom: map.getZoom()
      		}));

      map.addListener('dragend', () =>
      		app.ports.updateViewport.send({
      			center: map.getCenter(),
      			zoom: map.getZoom()
      		}));
    }

    map.setOptions(opts.viewport);

    clearAllMarkers();

    active_markers = opts.pins.map(pin => {
    	let marker = null;

    	if (inactive_markers.length > 0) {
        marker = inactive_markers.pop();
        active_markers.push(marker);
    	}
      else {
    		marker = new google.maps.Marker();
    	}

    	marker.setOptions({ position: pin.position, map: map });
    	marker.addListener('click', () => app.ports.showIncident.send(pin.id));

      return marker;
    });
  });
  // app.ports.mapMoved.send()
});

window.initMap = () => {
  app.ports.mapReady.send();
};

