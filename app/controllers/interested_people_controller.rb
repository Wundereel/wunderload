class InterestedPeopleController < ApplicationController
  respond_to :json

  def new
    @interested_person = InterestedPerson.new
  end

  def create
    params[:interested_person][:client_ip] = request.ip
    @interested_person = InterestedPerson.new people_params

    respond_to do |format|
      if @interested_person.save
        WundereelNotifications.non_dropbox_email(@interested_person).deliver_later

        format.html { redirect_to success_interested_people_path }
        format.json { redirect_to success_interested_people_path }
      else
        format.html { render :new }
        format.json {
          render json: @interested_person.errors,
                 status: :unprocessable_entity
        }
      end
    end
  end

  def success
  end

  def people_params
    params.require(:interested_person).permit(:email, :client_ip)
  end
end
