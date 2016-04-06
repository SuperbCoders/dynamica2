namespace :dynamica do
  namespace :permissions do

    def add_all_permissions(project, user)
      user.permissions.find_or_create_by! project: project,
          manage: true,
          read: true,
          forecasting: true,
          api: true
    end

    desc 'give access to project for user'
    task :to_all, [:project_id] => :environment do |t, args|
      project = Project.find(args.project_id)

      User.all.each do |user|
        add_all_permissions(project, user)
      end
    end

    desc 'give acccess to specified user'
    task :to_one, [:project_id, :user_id] => :environment do |t, args|
      project = Project.find(args.project_id)
      user = User.find(args.user_id)

      add_all_permissions(project, user)
    end
  end
end

