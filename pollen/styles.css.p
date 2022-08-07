root {
  letter-spacing: 0.0125em;
}

#header .name {
  position: absolute;
  left: 30%;
  top: 50%;
  font-size: 10vh;
  width: 8em;
  font-variant: small-caps;
  transform: translateX(-50%) rotate(-90deg);
  color: rgb(240, 240, 240);
}

h1, h2, h3, h4, h5 {
  font-variant: normal;
  color: rgb(11, 52, 95);
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
  color: rgb(79, 89, 97);
}

#heading address a {
  border: none;
}

dl {
  font-family: valkyrie_ot_b;
}

dl.bib dd {
  margin-bottom: .5em;
}

dt {
  position: absolute;
  right: calc(70% + .5rem);
  color: white;
  width: 9vw;
  text-align: right;
  font-size: 1.25vw;
}

dt.label {
  font-size: 1.75vw;
}

dd {
  padding-left: .5rem;
}

ul {
  font-family: valkyrie_ot_b;
  margin-left: 1rem;
}

ul li {
  padding-left: 0;
  margin-bottom: .75em;
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
  color: rgb(11, 52, 95);
  font-style: inherit;
}

strong {
  color: rgb(11, 52, 95);
  font-weight: bold;
}

.line {
  font-family: valkyrie_ot_b;
  padding-left: .5rem;
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