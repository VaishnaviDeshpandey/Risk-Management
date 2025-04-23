ActiveAdmin.register User do
    permit_params :email, :password, :password_confirmation, :username, :role
  
    index do
      selectable_column
      id_column
      column :email
      column :username
      column :role
      column :created_at
      actions
    end
  
    filter :email
    filter :username
    filter :role
    filter :created_at
  
    form do |f|
      f.inputs "User Details" do
        f.input :email
        f.input :username
        f.input :role, as: :select, collection: User::ROLES
        f.input :password
        f.input :password_confirmation
      end
      f.actions
    end
  
    show do
      attributes_table do
        row :email
        row :username
        row :role
        row :created_at
        row :updated_at
      end
    end
  end
  