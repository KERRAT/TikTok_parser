class UsersController < ApplicationController
  def index
    @users = User.includes(:user_socials).all
  end

  def show
    @user = User.find(params[:id])
  end
end
