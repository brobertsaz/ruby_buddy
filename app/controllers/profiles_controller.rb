class ProfilesController < ApplicationController
  before_action :authenticate_user!, except: %i[index show]
  before_action :set_profile, only: %i[ show edit update destroy ]

  # GET /profiles or /profiles.json
  def index
    @q = params[:q].to_s.strip
    @profiles = Profile.where(mentor: true).order(created_at: :desc)
    if @q.present?
      like = "%#{@q}%"
      @profiles = @profiles.where("name ILIKE ? OR skills ILIKE ? OR bio ILIKE ?", like, like, like)
    end
  end

  # GET /profiles/1 or /profiles/1.json
  def show
  end

  # GET /profiles/new
  def new
    @profile = current_user.build_profile
  end

  # GET /profiles/1/edit
  def edit
  end

  # POST /profiles or /profiles.json
  def create
    @profile = current_user.build_profile(profile_params)

    respond_to do |format|
      if @profile.save
        format.html { redirect_to @profile, notice: "Profile was successfully created." }
        format.json { render :show, status: :created, location: @profile }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @profile.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /profiles/1 or /profiles/1.json
  def update
    respond_to do |format|
      if @profile.update(profile_params)
        format.html { redirect_to @profile, notice: "Profile was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @profile }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @profile.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /profiles/1 or /profiles/1.json
  def destroy
    @profile.destroy!

    respond_to do |format|
      format.html { redirect_to profiles_path, notice: "Profile was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_profile
      @profile = Profile.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def profile_params
      params.expect(profile: [ :name, :bio, :years_experience, :timezone, :skills, :availability, :github_url, :x_url, :website_url, :mentor, :mentee ])
    end
end
