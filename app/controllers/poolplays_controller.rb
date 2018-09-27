require 'pry'
class PoolplaysController < ApplicationController
  include PoolplaysHelper
  include TournamentsHelper

  before_action :set_tournament
  before_action :start_pool_play_access, only: [:new, :create_temporary_pool, :create]
  before_action :set_poolplay, except: [:new, :create, :create_temporary_pool]
  before_action :restrict_access
  before_action :validate_team_numbers, only: [:new, :create]

  def index
  end

  def new
    if @tournament.poolplay_started
      redirect_to poolplay_path(@tournament.id)
    end
    @temp_pool = session[:temp_pool]
  end

  def create_temporary_pool
    @temp_pool_now = Poolplay.create_kob_pool(@tournament)
    session[:temp_pool] = @temp_pool_now
    @temp_pool_now
    respond_to do |format|
      # format.js {render layout: false}
      # binding.pry
      format.html { redirect_to new_poolplay_path @tournament.id }
      format.js {}
      format.json { render json: @temp_pool_now}
    end
    # redirect_to new_poolplay_path(@tournament)
  end

  def create
    if poolplay = Poolplay.save_kob_to_database(params["pool"], @tournament.id)
      flash[:success] = "Pool play has started"
      Tournament.update(@tournament.id, poolplay_started: true)
      session[:poolplay] = poolplay
      redirect_to poolplay_path(@tournament)
    else
      flash[:danger] = "Something went wrong"
      redirect_to new_poolplay_path(@tournament)
    end
  end

  def edit
  end

  def update
  end

  private

    def start_pool_play_access
      if @tournament.poolplay_started
        flash[:danger] = "You can not access this page, pool play has already started"
        redirect_to poolplay_path(@tournament)
      end
    end

    def set_tournament
      @tournament = Tournament.find(params[:id])
    end

    def restrict_access
      if @tournament.registration_open || @tournament.teams.length == 0 || @tournament.teams.length % 4 != 0
        flash[:danger] = "You can not enter pool play"
        redirect_to tournament_path(@tournament)
      end
    end

    def validate_team_numbers
      if @tournament.teams.length % 4 != 0
        flash[:danger] = "You do not have the right amount of teams.  Must be multiples of 4"
        redirect_to tournament_path(@tournament)
      end
    end

    def set_poolplay
      if session[:poolplay].nil?
        @poolplay = Poolplay.where("tournament_id = '#{@tournament.id}'")
        if @poolplay.empty?
          redirect_to new_poolplay_path(@tournament.id)
        end
        session[:poolplay] = @poolplay
      else
        @poolplay = session[:poolplay]
      end
      @courts = divide_pool_by_courts(@poolplay)

    end

    def set_teams(courts)
      teams = courts.keys.map do |court|
        courts[court].first["team_ids"].split("-").map do |team|
          team.split("/")
        end
      end.flatten.map(&:to_i)
    end



end
