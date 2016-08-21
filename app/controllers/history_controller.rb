class HistoryController < ApplicationController
  skip_before_filter :verify_authenticity_token

  def index
    histories = History.includes(:tags).all
    jsonRespose(histories.to_json( :include => [:tags] ), 200)

  end

  def create
    file = params[:history][:audio] #recover file to upload
    if !file.nil?
      m_params = params
      m_params.delete("audio") #delete uncessary hash

      file_name = Time.now.strftime("%Y_%d_%m_%H_%M_%S-%Z") + file.original_filename
      file_path = Rails.root.join('public', 'uploads', file_name)

      m_params["history"]["url"] = file_path.to_s #asign url to hash object

      if upload(file, file_path)
        history = History.new(history_params(m_params))
        if history.save
          jsonRespose(history.to_json( :include => [:tags] ), 200)
        else
          jsonRespose(history.errors, 400)
        end
      end
    else
       jsonRespose(file, 500)
    end

  end

  def add_like
    history = History.find(params[:history][:id])
    if !history.nil?
      history.likes = history.likes + 1

      if history.save
        jsonRespose(history, 200)
      else
        jsonRespose(history.errors, 400)
      end
    else
      jsonRespose(history, 500)
    end

  end


  def show
  end

  def destroy
  end

  private

    def history_params(m_params)
        m_params.require(:history).permit(:name, :latitude, :longitude, :url)
    end

    def upload (history_audio, file_path)
      history_audio_filename =  history_audio.original_filename
      File.open(file_path, 'wb') do |file|
        file.write(history_audio.read)
      end
    end

end