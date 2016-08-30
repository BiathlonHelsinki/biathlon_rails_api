class PlacesController < ApplicationController
  load_and_authorize_resource
  
  def create
    @place = Place.new(place_params)
    if @place.save
      render json: @place, status: :created, location: @place
    else
      render json: @place.errors, status: :unprocessable_entity
    end
  end
  
  def update
    @place = Place.friendly.find(params[:id])
    if @place.update_attributes(place_params)
      render json: @place, status: :created, location: @place
    else
      render json: @place.errors, status: :unprocessable_entity
    end
  end
  
  private
  
  def place_params
    params.require(:place).permit(:address1, :address2, :city, :country, :postcode, :latitude, :longitude, 
                                  translations_attributes: [:name, :id, :locale])
  end
    
  
end