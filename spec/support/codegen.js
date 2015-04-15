var fs = require('fs')
var path = require('path')
var _ = require('lodash')
var yaml = require('js-yaml');
var inflect = require('inflect');

function relativePath(p) {
    return path.join(__dirname, p)
}

var templateFile = fs.readFileSync(relativePath("../../lib/templates/resource.ejs"), 'utf8')

var helpers = {
  plural: inflect.pluralize,
  single: inflect.singularize,
  camel: inflect.camelize,
  cap: inflect.capitalize,
  decap: inflect.decapitalize,
  snake: inflect.underscore,
  dash: inflect.dasherize,
  param: inflect.parameterize,
  human: inflect.humanize,
  resources: ["unicorn", "world"]
}

_.forEach(helpers.resources, function(name) {
    var yamlFile = fs.readFileSync(relativePath("../templates/" + name + ".yaml"), 'utf8')
    var resource = yaml.load(yamlFile)
    var output = _.template(templateFile, resource, {imports: helpers, variable: 'resource'})

    fs.writeFile(relativePath("../templates/" + name + ".rb"), output, function(err) {
        if (err) return console.log(err)
        console.log(name + '.yaml > ' + name + '.rb')
    })
})
