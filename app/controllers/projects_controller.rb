class ProjectsController < ApplicationController
  load_and_authorize_resource
  before_action :set_project, only: [:show, :edit, :update, :destroy, :karma]

  # GET /projects
  # GET /projects.json
  def index
    @projects = Project.all
    @projects = @projects.name_like(params[:filter_name]) unless params[:filter_name].blank?
    @projects = @projects.author_like(params[:filter_author]) unless params[:filter_author].blank?
    @projects = @projects.locality_like(params[:filter_locality]) unless params[:filter_locality].blank?
    @projects = @projects.order(:name).page(params[:page])
  end

  def my
    @projects = current_user.own_projects
    @projects = @projects.order(:name).page(params[:page])
    render :index
  end

  def participating
    @projects = current_user.other_projects
    @projects = @projects.order(:name).page(params[:page])
    render :index
  end

  def create_position
  end

  # GET /projects/1
  # GET /projects/1.json
  def show
    project_id = params[:id]
    @project = Project.find(project_id)
    @positions = Position.includes(:skills)
    .where('positions_id = ?', project_id)
    @karma = Karma.find_by(author: current_user, karmable: @project)
  end

  # GET /projects/new
  def new
    @project = current_user.own_projects.build
  end

  # GET /projects/1/edit
  def edit
  end

  # POST /projects
  # POST /projects.json
  def create
    @project = current_user.own_projects.build(project_params)

    respond_to do |format|
      if @project.save && @project.author.add_role(:owner, @project)
        format.html { redirect_to @project, notice: 'Project was successfully created.' }
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /projects/1
  # PATCH/PUT /projects/1.json
  def update
    respond_to do |format|
      if @project.update(project_params)
        format.html { redirect_to @project, notice: 'Project was successfully updated.' }
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /projects/1
  # DELETE /projects/1.json
  def destroy
    @project.destroy
    respond_to do |format|
      format.html { redirect_to projects_url, notice: 'Project was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def karma
    @karma = Karma.find_by(author: current_user, karmable: @project)
    if @karma
      @karma.destroy
    else
      @karma = Karma.new
      @karma.author = current_user
      @karma.karmable = @project

      @karma.save && @karma.author.add_role(:owner, @karma)
    end

    redirect_to @project
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_project
      params[:id] ||= params[:project_id]
      @project = Project.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def project_params
      params.require(:project).permit(:name,:description,:locality)
    end
end
