### WARNING: This file is auto-generated by the asana-api-meta repo. Do not
### edit it manually.

module Asana
  module Resources
    # The _task_ is the basic object around which many operations in Asana are
    # centered. In the Asana application, multiple tasks populate the middle pane
    # according to some view parameters, and the set of selected tasks determines
    # the more detailed information presented in the details pane.
    class Task < Resource

      include AttachmentUploading

      include EventSubscription


      attr_reader :id

      attr_reader :assignee

      attr_reader :assignee_status

      attr_reader :created_at

      attr_reader :completed

      attr_reader :completed_at

      attr_reader :custom_fields

      attr_reader :due_on

      attr_reader :due_at

      attr_reader :external

      attr_reader :followers

      attr_reader :hearted

      attr_reader :hearts

      attr_reader :modified_at

      attr_reader :name

      attr_reader :notes

      attr_reader :num_hearts

      attr_reader :projects

      attr_reader :parent

      attr_reader :workspace

      attr_reader :memberships

      attr_reader :tags

      class << self
        # Returns the plural name of the resource.
        def plural_name
          'tasks'
        end

        # Creating a new task is as easy as POSTing to the `/tasks` endpoint
        # with a data block containing the fields you'd like to set on the task.
        # Any unspecified fields will take on default values.
        #
        # Every task is required to be created in a specific workspace, and this
        # workspace cannot be changed once set. The workspace need not be set
        # explicitly if you specify `projects` or a `parent` task instead.
        #
        # `projects` can be a comma separated list of projects, or just a single
        # project the task should belong to.
        #
        # workspace - [Id] The workspace to create a task in.
        # options - [Hash] the request I/O options.
        # data - [Hash] the attributes to post.
        def create(client, workspace: nil, options: {}, **data)
          with_params = data.merge(workspace: workspace).reject { |_,v| v.nil? || Array(v).empty? }
          self.new(parse(client.post("/tasks", body: with_params, options: options)).first, client: client)
        end

        # Creating a new task is as easy as POSTing to the `/tasks` endpoint
        # with a data block containing the fields you'd like to set on the task.
        # Any unspecified fields will take on default values.
        #
        # Every task is required to be created in a specific workspace, and this
        # workspace cannot be changed once set. The workspace need not be set
        # explicitly if you specify a `project` or a `parent` task instead.
        #
        # workspace - [Id] The workspace to create a task in.
        # options - [Hash] the request I/O options.
        # data - [Hash] the attributes to post.
        def create_in_workspace(client, workspace: required("workspace"), options: {}, **data)

          self.new(parse(client.post("/workspaces/#{workspace}/tasks", body: data, options: options)).first, client: client)
        end

        # Returns the complete task record for a single task.
        #
        # id - [Id] The task to get.
        # options - [Hash] the request I/O options.
        def find_by_id(client, id, options: {})

          self.new(parse(client.get("/tasks/#{id}", options: options)).first, client: client)
        end

        # Returns the compact task records for all tasks within the given project,
        # ordered by their priority within the project.
        #
        # projectId - [Id] The project in which to search for tasks.
        # per_page - [Integer] the number of records to fetch per page.
        # options - [Hash] the request I/O options.
        def find_by_project(client, projectId: required("projectId"), per_page: 20, options: {})
          params = { limit: per_page }.reject { |_,v| v.nil? || Array(v).empty? }
          Collection.new(parse(client.get("/projects/#{projectId}/tasks", params: params, options: options)), type: self, client: client)
        end

        # Returns the compact task records for all tasks with the given tag.
        #
        # tag - [Id] The tag in which to search for tasks.
        # per_page - [Integer] the number of records to fetch per page.
        # options - [Hash] the request I/O options.
        def find_by_tag(client, tag: required("tag"), per_page: 20, options: {})
          params = { limit: per_page }.reject { |_,v| v.nil? || Array(v).empty? }
          Collection.new(parse(client.get("/tags/#{tag}/tasks", params: params, options: options)), type: self, client: client)
        end

        # Returns the compact task records for some filtered set of tasks. Use one
        # or more of the parameters provided to filter the tasks returned. You must
        # specify a `project` or `tag` if you do not specify `assignee` and `workspace`.
        #
        # assignee - [String] The assignee to filter tasks on.
        # project - [Id] The project to filter tasks on.
        # workspace - [Id] The workspace or organization to filter tasks on.
        # completed_since - [String] Only return tasks that are either incomplete or that have been
        # completed since this time.
        #
        # modified_since - [String] Only return tasks that have been modified since the given time.
        #
        # per_page - [Integer] the number of records to fetch per page.
        # options - [Hash] the request I/O options.
        # Notes:
        #
        # If you specify `assignee`, you must also specify the `workspace` to filter on.
        #
        # If you specify `workspace`, you must also specify the `assignee` to filter on.
        #
        # A task is considered "modified" if any of its properties change,
        # or associations between it and other objects are modified (e.g.
        # a task being added to a project). A task is not considered modified
        # just because another object it is associated with (e.g. a subtask)
        # is modified. Actions that count as modifying the task include
        # assigning, renaming, completing, and adding stories.
        def find_all(client, assignee: nil, project: nil, workspace: nil, completed_since: nil, modified_since: nil, per_page: 20, options: {})
          params = { assignee: assignee, project: project, workspace: workspace, completed_since: completed_since, modified_since: modified_since, limit: per_page }.reject { |_,v| v.nil? || Array(v).empty? }
          Collection.new(parse(client.get("/tasks", params: params, options: options)), type: self, client: client)
        end
      end

      # A specific, existing task can be updated by making a PUT request on the
      # URL for that task. Only the fields provided in the `data` block will be
      # updated; any unspecified fields will remain unchanged.
      #
      # When using this method, it is best to specify only those fields you wish
      # to change, or else you may overwrite changes made by another user since
      # you last retrieved the task.
      #
      # Returns the complete updated task record.
      #
      # options - [Hash] the request I/O options.
      # data - [Hash] the attributes to post.
      def update(options: {}, **data)

        refresh_with(parse(client.put("/tasks/#{id}", body: data, options: options)).first)
      end

      # A specific, existing task can be deleted by making a DELETE request on the
      # URL for that task. Deleted tasks go into the "trash" of the user making
      # the delete request. Tasks can be recovered from the trash within a period
      # of 30 days; afterward they are completely removed from the system.
      #
      # Returns an empty data record.
      def delete()

        client.delete("/tasks/#{id}") && true
      end

      # Adds each of the specified followers to the task, if they are not already
      # following. Returns the complete, updated record for the affected task.
      #
      # followers - [Array] An array of followers to add to the task.
      # options - [Hash] the request I/O options.
      # data - [Hash] the attributes to post.
      def add_followers(followers: required("followers"), options: {}, **data)
        with_params = data.merge(followers: followers).reject { |_,v| v.nil? || Array(v).empty? }
        refresh_with(parse(client.post("/tasks/#{id}/addFollowers", body: with_params, options: options)).first)
      end

      # Removes each of the specified followers from the task if they are
      # following. Returns the complete, updated record for the affected task.
      #
      # followers - [Array] An array of followers to remove from the task.
      # options - [Hash] the request I/O options.
      # data - [Hash] the attributes to post.
      def remove_followers(followers: required("followers"), options: {}, **data)
        with_params = data.merge(followers: followers).reject { |_,v| v.nil? || Array(v).empty? }
        refresh_with(parse(client.post("/tasks/#{id}/removeFollowers", body: with_params, options: options)).first)
      end

      # Returns a compact representation of all of the projects the task is in.
      #
      # per_page - [Integer] the number of records to fetch per page.
      # options - [Hash] the request I/O options.
      def projects(per_page: 20, options: {})
        params = { limit: per_page }.reject { |_,v| v.nil? || Array(v).empty? }
        Collection.new(parse(client.get("/tasks/#{id}/projects", params: params, options: options)), type: Project, client: client)
      end

      # Adds the task to the specified project, in the optional location
      # specified. If no location arguments are given, the task will be added to
      # the beginning of the project.
      #
      # `addProject` can also be used to reorder a task within a project that
      # already contains it.
      #
      # Returns an empty data block.
      #
      # project - [Id] The project to add the task to.
      #
      # insert_after - [Id] A task in the project to insert the task after, or `nil` to
      # insert at the beginning of the list.
      #
      # insert_before - [Id] A task in the project to insert the task before, or `nil` to
      # insert at the end of the list.
      #
      # section - [Id] A section in the project to insert the task into. The task will be
      # inserted at the top of the section.
      #
      # options - [Hash] the request I/O options.
      # data - [Hash] the attributes to post.
      def add_project(project: required("project"), insert_after: :not_provided, insert_before: :not_provided, section: nil, options: {}, **data)
        with_params = data.merge(project: project, insert_after: insert_after, insert_before: insert_before, section: section).reject { |_,v| v.nil? || Array(v).empty? || v == :not_provided }
        with_params[:insert_after] = nil if insert_after.nil?
        with_params[:insert_before] = nil if insert_before.nil?
        client.post("/tasks/#{id}/addProject", body: with_params, options: options) && true
      end

      # Removes the task from the specified project. The task will still exist
      # in the system, but it will not be in the project anymore.
      #
      # Returns an empty data block.
      #
      # project - [Id] The project to remove the task from.
      # options - [Hash] the request I/O options.
      # data - [Hash] the attributes to post.
      def remove_project(project: required("project"), options: {}, **data)
        with_params = data.merge(project: project).reject { |_,v| v.nil? || Array(v).empty? }
        client.post("/tasks/#{id}/removeProject", body: with_params, options: options) && true
      end

      # Returns a compact representation of all of the tags the task has.
      #
      # per_page - [Integer] the number of records to fetch per page.
      # options - [Hash] the request I/O options.
      def tags(per_page: 20, options: {})
        params = { limit: per_page }.reject { |_,v| v.nil? || Array(v).empty? }
        Collection.new(parse(client.get("/tasks/#{id}/tags", params: params, options: options)), type: Tag, client: client)
      end

      # Adds a tag to a task. Returns an empty data block.
      #
      # tag - [Id] The tag to add to the task.
      # options - [Hash] the request I/O options.
      # data - [Hash] the attributes to post.
      def add_tag(tag: required("tag"), options: {}, **data)
        with_params = data.merge(tag: tag).reject { |_,v| v.nil? || Array(v).empty? }
        client.post("/tasks/#{id}/addTag", body: with_params, options: options) && true
      end

      # Removes a tag from the task. Returns an empty data block.
      #
      # tag - [Id] The tag to remove from the task.
      # options - [Hash] the request I/O options.
      # data - [Hash] the attributes to post.
      def remove_tag(tag: required("tag"), options: {}, **data)
        with_params = data.merge(tag: tag).reject { |_,v| v.nil? || Array(v).empty? }
        client.post("/tasks/#{id}/removeTag", body: with_params, options: options) && true
      end

      # Returns a compact representation of all of the subtasks of a task.
      #
      # per_page - [Integer] the number of records to fetch per page.
      # options - [Hash] the request I/O options.
      def subtasks(per_page: 20, options: {})
        params = { limit: per_page }.reject { |_,v| v.nil? || Array(v).empty? }
        Collection.new(parse(client.get("/tasks/#{id}/subtasks", params: params, options: options)), type: self.class, client: client)
      end

      # Creates a new subtask and adds it to the parent task. Returns the full record
      # for the newly created subtask.
      #
      # options - [Hash] the request I/O options.
      # data - [Hash] the attributes to post.
      def add_subtask(options: {}, **data)

        self.class.new(parse(client.post("/tasks/#{id}/subtasks", body: data, options: options)).first, client: client)
      end

      # Changes the parent of a task. Each task may only be a subtask of a single
      # parent, or no parent task at all. Returns an empty data block.
      #
      # parent - [Id] The new parent of the task, or `null` for no parent.
      # options - [Hash] the request I/O options.
      # data - [Hash] the attributes to post.
      def set_parent(parent: required("parent"), options: {}, **data)
        with_params = data.merge(parent: parent).reject { |_,v| v.nil? || Array(v).empty? || v == :not_provided }
        with_params[:parent] = nil if parent.nil?
        client.post("/tasks/#{id}/setParent", body: with_params, options: options) && true
      end

      # Returns a compact representation of all of the stories on the task.
      #
      # per_page - [Integer] the number of records to fetch per page.
      # options - [Hash] the request I/O options.
      def stories(per_page: 20, options: {})
        params = { limit: per_page }.reject { |_,v| v.nil? || Array(v).empty? }
        Collection.new(parse(client.get("/tasks/#{id}/stories", params: params, options: options)), type: Story, client: client)
      end

      # Adds a comment to a task. The comment will be authored by the
      # currently authenticated user, and timestamped when the server receives
      # the request.
      #
      # Returns the full record for the new story added to the task.
      #
      # text - [String] The plain text of the comment to add.
      # options - [Hash] the request I/O options.
      # data - [Hash] the attributes to post.
      def add_comment(text: required("text"), options: {}, **data)
        with_params = data.merge(text: text).reject { |_,v| v.nil? || Array(v).empty? }
        Story.new(parse(client.post("/tasks/#{id}/stories", body: with_params, options: options)).first, client: client)
      end

    end
  end
end
