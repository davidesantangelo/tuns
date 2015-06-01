class StaticController < ApplicationController
  def index
  end

  def privacy
    cookies[:acceptterms] = true
  end

  def acceptterms
  	cookies[:acceptterms] = true
  	redirect_to :back
  end
end