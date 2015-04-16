module Asana
  module Resources
    # Internal: Mixin to add the ability to upload an attachment to a specific
    # Asana resource (a Task, really).
    module AttachmentUploading
      # Uploads a new attachment to the resource.
      #
      # filename - [String] the absolute path of the file to upload.
      # mime     - [String] the MIME type of the file
      # data     - [Hash] extra attributes to post.
      def attach(filename:, mime:, **data)
        path = File.expand_path(filename)
        unless File.exist?(path)
          fail ArgumentError, "file #{filename} doesn't exist"
        end
        upload = Faraday::UploadIO.new(path, mime)
        response = client.post("/#{self.class.plural_name}/#{id}/attachments",
                               body: data,
                               upload: upload)
        Attachment.new(body(response), client: client)
      end
    end
  end
end
