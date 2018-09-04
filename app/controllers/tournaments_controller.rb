class TournamentsController < ApplicationController

  before_action :set_tournament, only: [:show, :edit]

  def index
    @tournaments = Tournament.all
  end

  def new
    @tournament = Tournament.new
  end

  def create
    @tournament = Tournament.new(tournament_params)
    if @tournament.save
      flash[:success] = "Tournament has been created"
      redirect_to tournaments_path
    else
      flash.now[:danger] = "Tournament has not been created"
      render :new
    end
  end

  def show
  end

  def edit
  end

  private

    def set_tournament
      @tournament = Tournament.find(params[:id])
    end

    def tournament_params
      params.require(:tournament).permit(:name, :date_played, :registration_open, :closed)
    end
end
