module Asana
  module Resources
    # Internal: Mixin to add the ability to upload an attachment to a specific
    # Asana resource (a Task, really).
    module AttachmentUploading
      # Uploads a new attachment to the resource.
      #
      # filename - [String] the absolute path of the file to upload.
      # mime     - [String] the MIME type of the file
      # options  - [Hash] the request I/O options
      # data     - [Hash] extra attributes to post
      #
      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/MethodLength
      def attach(filename: required('filename'),
                 mime: required('mime'),
                 options: {}, **data)
        path = File.expand_path(filename)
        unless File.exist?(path)
          raise ArgumentError, "file #{filename} doesn't exist"
        end
        upload = Faraday::UploadIO.new(path, mime)
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
