class StaticController < ApplicationController
  def index
  end

  def privacy
    cookies.permanent[:acceptterms] = true
  end

  def acceptterms
  	cookies.permanent[:acceptterms] = true
  	redirect_to :back
  end
end