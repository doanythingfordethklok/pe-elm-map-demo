import { Elm } from "./elm/Main.elm";
import './style/index.scss';

const incident1 = require('../data/F01705150050.json');
const incident2 = require('../data/F01705150090.json');

Elm.Main.init({
 	node: document.getElementById("root"),
 	flags: [ incident1, incident2 ]
});

