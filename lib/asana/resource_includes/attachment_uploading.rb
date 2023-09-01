# frozen_string_literal: true

require 'faraday/multipart'

module Asana
  module Resources
    # Internal: Mixin to add the ability to upload an attachment to a specific
    # Asana resource (a Task, really).
    module AttachmentUploading
      # Uploads a new attachment to the resource.
      #
      # filename - [String] the absolute path of the file to upload OR the desired filename when using +io+
      # mime     - [String] the MIME type of the file
      # io       - [IO] an object which returns the file's content on +#read+, e.g. a +::StringIO+
      # options  - [Hash] the request I/O options
      # data     - [Hash] extra attributes to post
      #
      def attach(filename: Asana::CompatibilityHelper.required('filename'),
                 mime: Asana::CompatibilityHelper.required('mime'),
                 io: nil, options: {}, **data)

        upload = if io.nil?
                   path = File.expand_path(filename)
                   raise ArgumentError, "file #{filename} doesn't exist" unless File.exist?(path)

                   Faraday::Multipart::FilePart.new(path, mime)
                 else
                   Faraday::Multipart::FilePart.new(io, mime, filename)
                 end

        response = client.post("/#{self.class.plural_name}/#{gid}/attachments",
                               body: data,
                               upload: upload,
                               options: options)

        Attachment.new(parse(response).first, client: client)
      end
    end
  end
end
