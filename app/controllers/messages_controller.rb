class MessagesController < ApplicationController

  before_filter :check_priviledges, :except => [:new, :create]

  def check_priviledges
    not_found and return unless current_user.present?
    case current_user.role
      when "admin"
      when "moderator"
        not_found unless [:index, :show, :edit, :update].include? params[:action].to_sym
      when "user"
        not_found unless [:index, :show].include? params[:action].to_sym
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
      @messages = Message.paginate_by_sql("
        SELECT `messages`.*, COUNT(`f2`.`flaggable_id`) AS `flaggers` FROM `messages`
        LEFT JOIN `flaggings` AS `f` ON `f`.`flaggable_id`=`messages`.`id`
        LEFT JOIN `flaggings` AS `f2` ON `f2`.`flaggable_id`=`messages`.`id`
        WHERE (`f`.`flaggable_type`='Message' AND `f`.`flag`='visible_to'
        AND `f`.`flagger_id`=#{current_user.id}) OR `f`.`flaggable_id` IS NULL
        GROUP BY `messages`.`id` ORDER BY `messages`.`created_at` DESC
        ", :page => params[:page], :per_page => @per_page)
    else
      @messages = Message.paginate_by_sql("
        SELECT `messages`.*, COUNT(`f`.`flaggable_id`) AS `flaggers` FROM `messages`
        LEFT JOIN `flaggings` AS `f` ON `f`.`flaggable_id`=`messages`.`id`
        WHERE (`f`.`flaggable_type`='Message' AND `f`.`flag`='visible_to') OR `f`.`flaggable_id` IS NULL
        GROUP BY `messages`.`id` ORDER BY `messages`.`created_at` DESC
      ", :page => params[:page], :per_page => @per_page)
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
    @message.visible_to = @message.flaggings.with_flag(:visible_to)
    @message.ip_info.gsub!(/,|:/, "\\0 ").gsub!('""', '(n/a)').gsub!(/\{|\}|"/, "") unless @message.ip_info.nil?

    if is_user?
      not_found and return unless @message.visible_to.empty? or
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
    @show_editable_fields = true

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @message }
    end
  end

  # GET /messages/1/edit
  def edit
    @message = Message.find(params[:id])
    @show_editable_fields = is_admin?
    @visible_to = @message.flaggings.with_flag(:visible_to)
  end

  # POST /messages
  # POST /messages.json
  def create
    @message = Message.new(params[:message])

    @message.ip_address = request.remote_ip
    http = Net::HTTP.new("int.dpool.sina.com.cn")
    http.open_timeout = 5
    http.read_timeout = 5
    begin
      http.start
      begin
        http.request_get("/iplookup/iplookup.php?format=js&ip=#{@message.ip_address}") do |response|
          info = response.body[/{.*}/,0]
          json = JSON.parse info
          if json["ret"] == 1
            json.slice!("country", "province", "city", "district", "isp")
            @message.ip_info = json.to_json
          end
        end
      rescue Timeout::Error
      end
    rescue Timeout::Error
    end

    @show_editable_fields = true

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

    @show_editable_fields = is_admin?

    respond_to do |format|
      if is_moderator?
        # moderator can't update message
        format.html { redirect_to @message, notice: 'Message was successfully updated.' }
        format.json { head :no_content }
      else
        if @message.update_attributes(params[:message])
          format.html { redirect_to @message, notice: 'Message was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @message.errors, status: :unprocessable_entity }
        end
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
