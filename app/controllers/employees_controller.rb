class EmployeesController < AuthenticatedController
  before_action :check_required_settings
  before_action { check_permissions_for(:business) }

  helper_method :employees, :employee

  def create
    @employee = User.new(employee_params)
    @employee.password_confirmation = employee_params[:password]
    @employee.role = "employee"
    @employee.business_id = current_user.id
    @employee.agree_to_terms_and_service = true
    @employee.skip_confirmation!
    if @employee.save
      @employee.confirm
      GenericMailer.added_into_business(employee_params).deliver
      flash[:notice] = "Employee created successully!"
      respond_to do |format|
        format.js {
          render layout: false, message: "Employee created successully!", content_type: 'text/javascript'
        }
        format.html {
          redirect_to employees_path
        }
      end
    else
      @error = "Employee is invalid!"
      flash[:error] = @error
      respond_to do |format|
        format.js   { render layout: false, message: @error, content_type: 'text/javascript' }
        format.html {
          render :index
        }
      end
    end
  end

  def update
    employee.update_attribute("all_notifications", !employee.all_notifications)
    head :ok
  end

  def destroy
    employee.destroy
    flash[:notice] = "Employee destroyed successully!"
    redirect_to employees_path
  end

  protected

  def employee
    if params[:id]
      @_employee ||= employees.find_by(slug: params[:id])
    else
      @employee ||= User.new
    end
  end

  def employees
    @employees ||= current_user.employees.in_order
  end

  def employee_params
    params.require(:user).permit(:name, :email, :password, :phone_number)
  end
end
