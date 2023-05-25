#lang pollen

◊(define bright-color "rgb(240, 240, 240)")
◊(define dark-color   "rgb( 11,  52,  95)")
◊(define dark-color-05 "rgba( 11,  52,  95, 0.5)")
◊(define gray-color   "rgb( 79,  89,  97)")
◊(define text-color   "rgb( 66,  66,  66)")

#root {
  line-height: 1.45;
  text-rendering: optimizeLegibility;
  padding-top: 4em;
  color: ◊text-color;
}

#header .name {
  position: absolute;
  left: 30%;
  top: 50%;
  font-size: 10vh;
  width: 8em;
  font-variant: small-caps;
  transform: translateX(-50%) rotate(-90deg);
  color: ◊bright-color;
}

h1, h2, h3, h4, h5 {
  font-variant: normal;
  color: ◊dark-color;
  background-color: transparent;
  margin-bottom: 0.5em;
}

h1 {
  font-size: 3em;
  font-family: concourse_ot_6_semibold;
  padding-left: .5rem;
}

h1 span {
  color: white;
  position: absolute;
  right: calc(70% + .5rem);
}

h2 {
  font-size: 1.4em;
  padding-left: .5rem;
}

h2:before {
  content: '';
  position: absolute;
  right: calc(70% + .5rem);
  margin-top: .6em;
  width: 10vw;
  height: .75rem;
  background: white;
}

h3 {
  font-size: 1.125em;
  padding-left: .5rem;
}

#heading {
  float: left;
  width: 100%;
}

#heading h1 {
  float: left;
}

#heading address {
  float: right;
  text-align: right;
  line-height: 1.35;
  padding-top: 1rem;
  font-size: 95%;
  color: ◊gray-color;
}

#heading address a {
  border: none;
}

dl {
  font-family: valkyrie_ot_b;
}

dl.bib dd {
  margin-bottom: 2em;
}

dl.bib dd div.bib-item {
  box-shadow: 0 4px 8px 0 ◊dark-color-05;
}

dl.bib dd div.bib-item-header {
  padding: .5rem 1rem;
  background: ◊dark-color;
  color: ◊bright-color;
}

dl.bib dd div.bib-item-body {
  padding: .5rem 1rem;
}

dl.bib dd div.bib-item-header h1 {
  padding-left: 0;
  font-family: valkyrie_ot_b;
  font-size: 1em;
  font-weight: bold;
  color: ◊bright-color;
  margin-bottom: 0;
}

dl.bib dd div.bib-item div.title {
  background: ◊dark-color;
  color: ◊bright-color;
}

dl.bib dd div.bib-item div.authors {
  font-style: italic;
  margin-bottom: .5em;
}

dl.bib dd div.bib-item div.journal {
  margin-bottom: .5em;
}

◊; dl.bib dd div.bib-item div.journal span {
◊;   background: ◊dark-color;
◊;   color: ◊bright-color;
◊;   padding: 0 .25rem;
◊; }

◊; dl.bib dd div.bib-item div.journal span em {
◊;   color: ◊bright-color;
◊; }

dl.bib dd div.bib-item div.notes {
}

dt {
  position: absolute;
  right: calc(70% + .5rem);
  color: white;
  width: 14vw;
  text-align: right;
  font-size: .85em;
  padding-top: .25rem;
}

dt.label {
  font-size: 1em;
  padding-top: 0;
}

dd {
  padding-left: .5rem;
  margin-bottom: .5em;
}

ul {
  font-family: valkyrie_ot_b;
  margin-left: 1rem;
  color: black;
}

ul li {
  padding-left: 0;
  margin-bottom: .25em;
  list-style-type: disc;
  color: ◊dark-color;
}

ul.inline {
  margin: 0;
}

dd div.left {
  float: left;
}

dd div.right {
  float: right;
}

em {
  color: ◊dark-color;
  font-style: inherit;
}

strong {
  color: ◊dark-color;
  font-weight: bold;
}

.line {
  font-family: valkyrie_ot_b;
  padding-left: .5rem;
  margin-bottom: .75em;
}

.smaller {
  font-size: 90%;
}

.even-smaller {
  font-size: 80%;
}

.bigger {
  font-size: 110%;
}