module.exports = {
  resource: {
    template: 'resource.ejs',
    filename: function(resource, helpers) {
      return resource.name + '.rb';
    }
  }
};
