require "google/api_client"
require "trollop"

YOUTUBE_API_SERVICE_NAME = "youtube"
YOUTUBE_API_VERSION = "v3"

def getService
  client = Google::APIClient.new(
    :key => ENV['GOOGLE_API_KEY'],
    :authorization => nil,
    :application_name => "YouPlayAlong",
    :application_version => "1.0.0"
  )
  youtube = client.discovered_api(YOUTUBE_API_SERVICE_NAME, YOUTUBE_API_VERSION)

  return client, youtube
end

def getVideoId(search_term)
	opts = Trollop::options do
		opt :q, "Search term", :type => String, :default => "#{search_term}"
		opt :max_results, "Max results", :type => :int, :default => 1
	end

	client, youtube = getService

	begin
		# Call the search.list method to retrieve results matching the specified
		# query term.
		search_response = client.execute!(
			:api_method => youtube.search.list,
			:parameters => {
			:part => "snippet",
			:q => opts[:q],
			:maxResults => opts[:max_results]
			}
		)

		ids = []
		videos = []
		channels = []
		playlists = []

		# Add each result to the appropriate list, and then display the lists of
		# matching videos, channels, and playlists.
		search_response.data.items.each do |search_result|
			case search_result.id.kind
			when "youtube#video"
				ids << search_result.id.videoId
				videos << "#{search_result.snippet.title} (#{search_result.id.videoId})"
			when "youtube#channel"
				channels << "#{search_result.snippet.title} (#{search_result.id.channelId})"
			when "youtube#playlist"
				playlists << "#{search_result.snippet.title} (#{search_result.id.playlistId})"
			end
		end

		puts "Videos:\n", videos, "\n"
		puts "Channels:\n", channels, "\n"
		puts "Playlists:\n", playlists, "\n"

		if (videos.length > 0)
			return ids[0]
		else
			puts "No videos found for query string #{search_term}."
			return nil
		end
	rescue Google::APIClient::TransmissionError => e
		puts e.result.body
		return nil
	end
end