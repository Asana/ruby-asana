var fs = require('fs')
var path = require('path')
var _ = require('lodash')
var yaml = require('js-yaml');
var inflect = require('inflect');

function relativePath(p) {
    return path.join(__dirname, p)
}

var yamlFile = fs.readFileSync(relativePath("../templates/unicorn.yaml"), 'utf8')
var templateFile = fs.readFileSync(relativePath("../../lib/templates/resource.ejs"), 'utf8')

var resource = yaml.load(yamlFile)

var helpers = {
  plural: inflect.pluralize,
  single: inflect.singularize,
  camel: inflect.camelize,
  cap: inflect.capitalize,
  decap: inflect.decapitalize,
  snake: inflect.underscore,
  dash: inflect.dasherize,
  param: inflect.parameterize,
  human: inflect.humanize
}

var output = _.template(templateFile, resource, {imports: helpers, variable: 'resource'})

fs.writeFile(relativePath("../templates/unicorn.rb"), output, function(err) {
    if (err) return console.log(err)
    console.log('unicorn.yaml > unicorn.rb')
})
