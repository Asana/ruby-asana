require_relative 'gen/jobs_base'

module Asana
  module Resources
    # A _job_ represents a process that handles asynchronous work.
    #
    # Jobs are created when an endpoint requests an action that will be handled asynchronously.
    # Such as project or task duplication.
    class Job < JobsBase


      attr_reader :gid

      attr_reader :resource_type

      attr_reader :resource_subtype

      attr_reader :status

      attr_reader :new_project

      attr_reader :new_task

      class << self
        # Returns the plural name of the resource.
        def plural_name
          'jobs'
        end

        # Returns the complete job record for a single job.
        #
        # id - [Gid] The job to get.
        # options - [Hash] the request I/O options.
        def find_by_id(client, id, options: {})

          self.new(parse(client.get("/jobs/#{id}", options: options)).first, client: client)
        end
      end

    end
  end
end
