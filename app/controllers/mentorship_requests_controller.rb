class MentorshipRequestsController < ApplicationController
  before_action :authenticate_user!, except: %i[index show]
  before_action :set_mentorship_request, only: %i[ show edit update destroy ]

  # GET /mentorship_requests or /mentorship_requests.json
  def index
    if user_signed_in?
      @mentorship_requests = MentorshipRequest.where("mentee_id = ? OR mentor_id = ?", current_user.id, current_user.id).order(created_at: :desc)
    else
      @mentorship_requests = MentorshipRequest.open.order(created_at: :desc)
    end
  end

  # GET /mentorship_requests/1 or /mentorship_requests/1.json
  def show
  end

  # GET /mentorship_requests/new
  def new
    @mentorship_request = MentorshipRequest.new
    @mentorship_request.mentor_id = params.dig(:mentorship_request, :mentor_id)
  end

  # GET /mentorship_requests/1/edit
  def edit
  end

  # POST /mentorship_requests or /mentorship_requests.json
  def create
    @mentorship_request = MentorshipRequest.new(mentorship_request_params)
    @mentorship_request.mentee = current_user

    respond_to do |format|
      if @mentorship_request.save
        current_user.update(onboarding_completed: true) if current_user.role.present? && !current_user.onboarding_completed?
        format.html { redirect_to @mentorship_request, notice: "Mentorship request was successfully created." }
        format.json { render :show, status: :created, location: @mentorship_request }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @mentorship_request.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /mentorship_requests/1 or /mentorship_requests/1.json
  def update
    respond_to do |format|
      if @mentorship_request.update(mentorship_request_params)
        format.html { redirect_to @mentorship_request, notice: "Mentorship request was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @mentorship_request }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @mentorship_request.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /mentorship_requests/1 or /mentorship_requests/1.json
  def destroy
    @mentorship_request.destroy!

    respond_to do |format|
      format.html { redirect_to mentorship_requests_path, notice: "Mentorship request was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  # POST /mentorship_requests/1/accept
  def accept
    @mentorship_request = MentorshipRequest.find(params[:id])

    if @mentorship_request.mentor_id == current_user.id
      @mentorship_request.update(status: :accepted)
      redirect_to @mentorship_request, notice: "Mentorship request accepted! You can now start chatting."
    else
      redirect_to @mentorship_request, alert: "You can only accept requests assigned to you."
    end
  end

  # POST /mentorship_requests/1/decline
  def decline
    @mentorship_request = MentorshipRequest.find(params[:id])

    if @mentorship_request.mentor_id == current_user.id
      @mentorship_request.update(status: :closed, mentor_id: nil)
      redirect_to mentorship_requests_path, notice: "Request declined."
    else
      redirect_to @mentorship_request, alert: "You can only decline requests assigned to you."
    end
  end

  # POST /mentorship_requests/1/close
  def close
    @mentorship_request = MentorshipRequest.find(params[:id])

    if @mentorship_request.mentee_id == current_user.id || @mentorship_request.mentor_id == current_user.id
      @mentorship_request.update(status: :closed)
      redirect_to mentorship_requests_path, notice: "Mentorship request closed."
    else
      redirect_to @mentorship_request, alert: "You don't have permission to close this request."
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_mentorship_request
      @mentorship_request = MentorshipRequest.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def mentorship_request_params
      params.expect(mentorship_request: [ :mentor_id, :topic, :goals, :preferred_times, :status ])
    end
end
