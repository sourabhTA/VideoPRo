class Api::V1::BaseController < ApplicationController

  private

  def user_authenticate
    token = request.headers["HTTP_AUTHORIZATION"]&.split(' ')&.last
    if params[:email].present? && token.present?
      @current_user = User.find_by(email: params[:email].downcase)
      return render json: {error: "Email not found"}, status: 401 unless @current_user.present?

      # user_token = (@current_user.tokens.values.last["token"] == token) ? @current_user.tokens.values.last : nil
      user_token = @current_user.present? ? @current_user.tokens.values.find {|x| x["token"] == token} : nil

      if user_token.present? && Time.at(user_token["expiry"]) > Time.now
        true
      else
        render json: {error: "Please Login again, Your Token is expired." }, status: 401
      end
    else
      render json: {error: "You are not Authorized" }, status: 401
    end
  end

end
