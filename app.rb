require "sinatra"
require "./youtube"

get "/" do
	erb :form
end

get "/v/:video_id" do |video_id|
	@video_id = video_id
	erb :result_page
end

post "/v" do
	@video_id = getVideoId(params[:search_term].to_s)
	if (@video_id == nil)
		redirect to ("")
	else
		redirect to ("v/#{@video_id}")
	end
end