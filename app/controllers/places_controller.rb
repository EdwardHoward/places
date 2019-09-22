class PlacesController < ApplicationController
  before_action :set_place, only: [:show, :edit, :update, :destroy]

  # GET /places
  # GET /places.json
  def index
    @places = Place.all
  end

  def search_place(query)
   Mapbox.access_token = Rails.application.credentials.mapbox[:access_token]
   Mapbox::Geocoder.geocode_forward(query, {
      "types" => "place,region,postcode", 
      "country" => "US"
   })
  end

  # GET /distance
  # GET /distance.json
  def distance
    if params[:q]
      results = search_place(params[:q])

      coords = results[0]["features"][0]["geometry"]["coordinates"]
      lng = coords[0]
      lat = coords[1]
    else 
      lng = params[:lng]
      lat = params[:lat]
    end

    dist = 'round((location <@> point(%s,%s))::numeric, 3) as miles' % [lat,lng]
    @places = Place.select("id, name, description, location", dist).where("round((location <@> point(:lat,:lng))::numeric, 3) < 5", {lat: lat, lng: lng}).order("miles");

    respond_to do |format|
      format.html
      format.json { render json: {markers: @places, location: [lat,lng]} }
    end
  end

  # GET /search
  # GET /search.json
  def search
    @results = searchPlace(params[:q])
    respond_to do |format|
      format.html
      format.json { render json: @results[0] }
    end
  end

  # GET /places/1
  # GET /places/1.json
  def show
  end

  # GET /places/new
  def new
    @place = Place.new
  end

  # GET /places/1/edit
  def edit
  end

  # POST /places
  # POST /places.json
  def create
    @place = Place.new(place_params)

    respond_to do |format|
      if @place.save
        format.html { redirect_to @place, notice: 'Place was successfully created.' }
        format.json { render :show, status: :created, location: @place }
      else
        format.html { render :new }
        format.json { render json: @place.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /places/1
  # PATCH/PUT /places/1.json
  def update
    respond_to do |format|
      if @place.update(place_params)
        format.html { redirect_to @place, notice: 'Place was successfully updated.' }
        format.json { render :show, status: :ok, location: @place }
      else
        format.html { render :edit }
        format.json { render json: @place.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /places/1
  # DELETE /places/1.json
  def destroy
    @place.destroy
    respond_to do |format|
      format.html { redirect_to places_url, notice: 'Place was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def set_place
      @place = Place.find(params[:id])
    end

    def place_params
      params.require(:place).permit(:name, :description, :location)
    end
end
