class CreditsController < ApplicationController
  
  
  before_action :authenticate_user!
  
  
  def create
    @credit = Credit.new(credit_params)
    if @credit.save
      render json: {data: @credit.ethtransaction}, status: 200
    else
      render json: @credit.errors, status: :unprocessable_entity
    end
  end
  
  def destroy
    credit = Credit.find(params[:id])
    credit.destroy!
    render json: @credit, status: :deleted
  end
  

  def index
    @credits = Credit.all.order(created_at: :desc)
  end
  
  def resubmit
    @credit = Credit.find(params[:id])
    if @credit.ethtransaction.confirmed != true
      if @credit.ethtransaction.timeof < 15.minutes.ago
        @credit.ethtransaction = nil
        @credit.save
        @credit.activities.each do |a|
          if a.ethtransaction
            if a.ethtransaction.confirmed != true
              a.ethtransaction.destroy
              a.destroy
            end
          end
        end
        if @credit.award_points
          render json: {data: @credit.ethtransaction}, status: 200
        else
          render json: @credit.errors, status: :unprocessable_entity
        end
      else
        render json: {error: 'Transaction is too recent, please wait 15 minutes and try again'},  status: :unprocessable_entity
      end
    else
      render json: {error: 'You cannot resubmit a verified blockchain transaction'},  status: :unprocessable_entity
    end
  end

  

  def update
    @credit = Credit.find(params[:id])
    if @credit.update_attributes(credit_params)
      render json: @credit, status: :updated
    else
      render json: @credit.errors, status: :unprocessable_entity
    end
  end

  
  protected
  
  def credit_params
    the_params =  params.require(:credit).permit(:attachment, :value, :user_id, :awarder_id, :description, 
                              :ethtransaction_id, :rate_id, :notes)  
    the_params[:attachment] = parse_image_data(the_params[:attachment]) if the_params[:attachment]
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
    extension = content_type.match(/gif|jpeg|png|pdf/).to_s
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