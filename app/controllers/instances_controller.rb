class InstancesController < ApplicationController
  include ActiveHashRelation
  load_and_authorize_resource except: [:onetimer,  :user_attend, :today], find_by: :slug
  before_action :authenticate_user!, except: [:user_attend, :today, :onetimer]
  before_action :authenticate_hardware!, only: [:user_attend,  :onetimer]

  
  def create
    @instance = Instance.new(instance_params)
    if @instance.save
      render json: {data: @instance}, status: 200
    else
      render json: {error: @instance.errors.full_messages.join(';')}, status: :unprocessable_entity
    end
  end
  
  def destroy
    @instance = Instance.friendly.find(params[:id])
    @instance.destroy!
    render json: @instance, status: :deleted
  end
  
  
  def onetimer
    event = Instance.friendly.find(params[:id])
    @onetimer = Onetimer.create(instance: event)
    if @onetimer.save
      Activity.create(user_id: 0, item: event,                   
                  description: 'attended_anonymously', onetimer: @onetimer, addition: 0 )
      render json: @onetimer, status: 200
    else
      render json: @onetimer.errors, status: :unprocessable_entity
    end
  end
  

  
  def update

    @instance = Instance.friendly.find(params[:id])
    if @instance.cancelled != true && params[:instance][:cancelled] == "1"
      Activity.create(user: current_user, item: @instance, ethtransaction_id: nil, description: 'cancelled_it', addition: 0)
    end
    if @instance.update_attributes(instance_params)
      render json: {data: @instance}, status: 200
    else
      render json: {error: @instance.errors.full_messages.join('; ')}, status: :unprocessable_entity
    end
  end
  
  def user_attend
      # this doesn't matter any more at this stage unless we are creating a new eth account
    # @geth_status = Net::Ping::TCP.new(ENV['geth_server'],  ENV['geth_port'], 1).ping?
    # @dapp_status = Net::Ping::TCP.new(ENV['dapp_server'],  ENV['dapp_port'], 1).ping?
    # if !@dapp_status
    #   render json: {error: {message: 'The Biathlon Dapp is not running.'}}, status: 422
    # elsif !@geth_status
    #   render json: {error: {message: 'The Ethereum client is not running.'}}, status: 422
    # else
    @user = User.friendly.find(params[:user_id])
    event = Instance.friendly.find(params[:id])
    if params[:visit_date]
      visit_date = params[:visit_date]
    else   
      visit_date = Time.now.to_date
    end

    transaction = @user.award_points(event, event.cost_bb, visit_date.to_s)

    if transaction
      if transaction["status"] == 'error'
        render json: {error: {message: transaction["message"]}}, status: :unprocessable_entity
      elsif transaction["error"]

        render json: {error: {message: transaction["message"]}}, status: :unprocessable_entity
      else
        # logger.warn('transaction output is ' + transaction.inspect)
        render json: UserSerializer.new(@user).serialized_json, status: 200
      end
    else
      # logger.warn(@user.errors.as_json(full_messages: true))
      render json: {error: {message: @user.errors.full_messages.join(', ') }}, status: :unprocessable_entity
    end
    # end
  end
  
  private
  
  def instance_params
    params[:instance][:event_attributes] = params[:instance][:experiment_attributes]
    params[:instance].delete(:experiment_attributes)
    the_params = params.require(:instance).permit(:published, :event_id, :place_id, :primary_sponsor_id, :is_meeting, :proposal_id, :survey_locked, 
    :secondary_sponsor_id, :cost_euros, :cost_bb, :sequence_id, :start_at, :end_at, :sequence, :allow_multiple_entry, :request_rsvp, 
    :request_registration, :parent_id, :image, :custom_bb_fee, :request_rsvp, :request_registration, :cancelled,
    :email_registrations_to, :question1_text, :question2_text, :question3_text, :question4_text, :boolean1_text, :send_to_pledgers,
    :boolean2_text, :require_approval, :hide_registrants, :show_guests_to_public, :max_attendees, 
    :registration_open, event_attributes: [:id, :secondary_sponsor_id], organiser_ids: [],
    translations_attributes: [:name, :description, :locale, :id]
    )

    the_params[:image] = parse_image_data(the_params[:image]) if the_params[:image]
    the_params
  end  
  

  def parse_image_data(base64_image)
    filename = "upload-image"
    # in_content_type, encoding, string = base64_image.split(/[:;,]/)[1..3]
    # logger.warn('string is ' + string.inspect)
    @tempfile = Tempfile.new(filename)
    @tempfile.binmode
    @tempfile.write Base64.decode64(base64_image)
    @tempfile.rewind

    # for security we want the actual content type, not just what was passed in
    content_type = `file --mime -b #{@tempfile.path}`.split(";")[0]

    # we will also add the extension ourselves based on the above
    # if it's not gif/jpeg/png, it will fail the validation in the upload model
    extension = content_type.match(/gif|jpeg|png/).to_s
    filename += ".#{extension}" if extension

    ActionDispatch::Http::UploadedFile.new({
      tempfile: @tempfile,
      content_type: content_type,
      filename: filename
    })
  end

  def clean_tempfile
    if @tempfile
      @tempfile.close
      @tempfile.unlink
    end
  end
  
end