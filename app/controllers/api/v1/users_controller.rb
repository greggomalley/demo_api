class Api::V1::UsersController < ApplicationController
  allow_unauthenticated_access

  def index
    @users = User.all.order(:email_address)
    render json: @users, include: [:industries]
  end
end