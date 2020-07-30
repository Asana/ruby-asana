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
      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/MethodLength
      def attach(filename: required('filename'),
                 mime: required('mime'),
                 io: nil, options: {}, **data)

        upload = if io.nil?
                   path = File.expand_path(filename)
                   raise ArgumentError, "file #{filename} doesn't exist" unless File.exist?(path)

                   Faraday::FilePart.new(path, mime)
                 else
                   Faraday::FilePart.new(io, mime, filename)
                 end

        response = client.post("/#{self.class.plural_name}/#{gid}/attachments",
                               body: data,
                               upload: upload,
                               options: options)

        Attachment.new(parse(response).first, client: client)
      end
      # rubocop:enable Metrics/MethodLength
      # rubocop:enable Metrics/AbcSize
    end
  end
end
