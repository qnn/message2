class MessagesController < ApplicationController

  before_filter :check_priviledges, :except => [:new, :create]

  def check_priviledges
    not_found and return unless current_user.present?
    case current_user.role
      when "admin"
      when "moderator"
      when "user"
        not_found if not [:index, :show].include? params[:action].to_sym
      else
        not_found
    end
  end

  User::ROLES.each do |role|
    define_method "is_#{role}?" do
      current_user.role == role
    end
  end

  # GET /messages
  # GET /messages.json
  def index
    if is_user?
      # Left Excluding JOIN
      @messages = Message.find_by_sql("SELECT `messages`.* FROM `messages`
        LEFT JOIN `flaggings` AS `f` ON `f`.`flaggable_id`=`messages`.`id`
        WHERE (`f`.`flaggable_type`='Message' AND `f`.`flag`='visible_to'
        AND `f`.`flagger_id`=#{current_user.id}) OR `f`.`flaggable_id` IS NULL")
    else
      @messages = Message.all
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @messages }
    end
  end

  # GET /messages/1
  # GET /messages/1.json
  def show
    @message = Message.find(params[:id])
    if is_user?
      not_found and return unless @message.flaggings.with_flag(:visible_to).empty? or
        @message.flagged_by?(current_user, :visible_to)
    end

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @message }
    end
  end

  # GET /messages/new
  # GET /messages/new.json
  def new
    @message = Message.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @message }
    end
  end

  # GET /messages/1/edit
  def edit
    @message = Message.find(params[:id])
    @visible_to = @message.flaggings.with_flag(:visible_to)
  end

  # POST /messages
  # POST /messages.json
  def create
    @message = Message.new(params[:message])

    respond_to do |format|
      if @message.save
        format.html { redirect_to new_message_path, notice: 'Message was successfully created.' }
        format.json { render json: @message, status: :created, location: @message }
      else
        format.html { render action: "new" }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /messages/1
  # PUT /messages/1.json
  def update
    @message = Message.find(params[:id])
    flaggers = @message.flaggings.with_flag(:visible_to).select('flagger_id').map { |f| f.flagger_id.to_s } || []
    visible_to = params[:visible_to] || []
    (visible_to - flaggers).each do |user|
      User.find(user).flag(@message, :visible_to)
    end
    (flaggers - visible_to).each do |user|
      User.find(user).unflag(@message, :visible_to)
    end

    respond_to do |format|
      if @message.update_attributes(params[:message])
        format.html { redirect_to @message, notice: 'Message was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /messages/1
  # DELETE /messages/1.json
  def destroy
    @message = Message.find(params[:id])
    @message.destroy

    respond_to do |format|
      format.html { redirect_to messages_url, notice: 'Message was successfully deleted.' }
      format.json { head :no_content }
    end
  end
end
