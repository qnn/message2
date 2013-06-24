class UsersController < ApplicationController

  before_filter :check_priviledges

  def check_priviledges
    not_found and return if !current_user.present? or current_user.role != "admin"
  end

  # GET /users
  # GET /users.json
  def index
    @users = User.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @users }
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
    @user = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/new
  # GET /users/new.json
  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(params[:user])

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render json: @user, status: :created, location: @user }
      else
        format.html { render action: "new" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.json
  def update
    @user = User.find(params[:id])

    force_log_out = false
    admin_count = User.where("role = ?", "admin").count
    if @user.role == "admin" && params[:user][:role] != "admin"
      if admin_count <= 1
        redirect_to :back, notice: 'You can not change the role of this user. Because there will be no admins.'
        return
      else
        force_log_out = true if @user.id == current_user.id
      end
    end

    # don't change password if it is empty
    params[:user].delete :password if params[:user][:password].empty?

    respond_to do |format|
      if @user.update_attributes(params[:user])
        if force_log_out
          sign_out current_user
          format.html { redirect_to root_path, notice: 'You are no longer an admin.' }
        else
          format.html { redirect_to @user, notice: 'User was successfully updated.' }
        end
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user = User.find(params[:id])

    if @user.id == current_user.id
      redirect_to :back, notice: 'You cannot delete yourself.'
      return
    elsif @user.id < current_user.id
      redirect_to :back, notice: 'You cannot delete admins with smaller ID than yours.'
      return
    end

    @user.destroy

    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully deleted.' }
      format.json { head :no_content }
    end
  end
end
