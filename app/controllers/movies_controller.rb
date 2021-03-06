class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @sort = params[:sort] || session[:sort]
    @movies = Movie.order(params[:sort]).all
    @all_ratings = Movie.order(:rating).select(:rating).map(&:rating).uniq
    @ratings = params[:ratings]  || session[:ratings]
    @ratings_to_show = Movie.ratings_to_show
    @with_ratings = Movie.with_ratings(@ratings_to_show)
    @ratings_to_show = checkbox
    @ratings_to_show.each do |rating|
      params[rating] = true
    end
    
    if params[:sort]
      @movies = Movie.order(params[:sort])
    else
      @movies = Movie.where(:rating => @ratings_to_show)
      session[:sort], session[:ratings] = @sort, @ratings
    end
    
    if params[:sort] != session[:sort] or params[:ratings] != session[:ratings]
      flash.keep
      redirect_to movies_path sort: @sort, ratings: @ratings
      session[:sort], session[:ratings] = @sort, @ratings
    end
    
    if params[:sort] == 'title'
      @title_header = 'hilite'
    end
    if params[:sort] == 'release_date'
      @release_header = 'hilite'
    end
    
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

  private
  # Making "internal" methods private is not required, but is a common practice.
  # This helps make clear which methods respond to requests, and which ones do not.
  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end
  
  def checkbox
    if params[:ratings]
      params[:ratings].keys
    else
      @all_ratings
    end
  end
end
