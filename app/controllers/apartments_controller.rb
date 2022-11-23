class ApartmentsController < ApplicationController
  before_action :set_apartment, only: %i[ show ]

  def index
    if params[:address].present?
      @apartments = Apartment.where("address LIKE ?", "%#{params[:location]}")
    else
      @apartments = policy_scope(Apartment)
    end
    @markers = set_markers
  end

  def show
    authorize(@apartment)
    @markers = [{
      lat: @apartment.latitude,
      lng: @apartment.longitude
    }]
  end

  def new
    @apartment = Apartment.new
    authorize(@apartment)
  end

  def create
    @apartment = Apartment.new(apartment_params)
    @apartment.user = current_user

    authorize(@apartment)

    if apartment.save
      redirect_to @apartment, notice: "Apartment successfully created"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_apartment
    @apartment = Apartment.find(params[:id])
  end

  def apartment_params
    params.require(:apartment).permit(:title, :address, :rating, :description, photos: [])
  end

  def set_markers
    @apartments.geocoded.map do |apartment|
      {
        lat: apartment.latitude,
        lng: apartment.longitude
      }
    end
  end
end
