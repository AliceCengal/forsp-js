const { readFileSync, writeFileSync } = require("fs");

const std = {
  name: "std.fp",
  cts: "std",
  uts: Date.now().toString(36),
  content: readFileSync('data/std.fp').toString()
}

const tutorial = {
  name: "tutorial.fp",
  cts: "tutorial",
  uts: Date.now().toString(36),
  content: readFileSync('data/tutorial.fp').toString()
}

const extensions = {
  name: "extensions.fp",
  cts: "extensions",
  uts: Date.now().toString(36),
  content: readFileSync('data/extensions.fp').toString()
}

const presets = { std, tutorial, extensions }

writeFileSync('./scripts/presets.json', JSON.stringify(presets))
