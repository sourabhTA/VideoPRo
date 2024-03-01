class Overrides::SessionsController < DeviseTokenAuth::SessionsController
	before_action :parameters

	def create
		begin
			user = User.find_by(email: params[:email].downcase)
			if user && user.valid_password?(params[:password])
				super do |resource|
				end
			else
				render json: {message: "Username or password not match."}, status: 200
			end
		rescue => e
			render json: {error: e.class.name, error_reason: e.message}, status: 401
		end
	end

  private

  def parameters
  	params.permit!
  end
end