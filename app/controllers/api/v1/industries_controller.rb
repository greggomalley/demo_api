class Api::V1::IndustriesController < ApplicationController
  allow_unauthenticated_access

  def index
    @industries = Industry.all.order(:name)
    render json: @industries
  end

  def show
    @industry = Industry.find(params[:id])
    render json: @industry
  end

  def create
    @industry = Industry.new(industry_params)
    if @industry.save
      render json: @industry, status: :created
    else
      render json: @industry.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @industry = Industry.find(params[:id])
    @industry.destroy
  end

  private

  def industry_params
    params.require(:industry).permit(:name)
  end
end