# PGSTuner.rb
# A wrapper around the grooveshark rubygem

require 'grooveshark'
require 'date'

class PGSTuner
	def initialize
		init_grooveshark
		@read_io, @write_io = IO.pipe
		@child = nil
	end

	def init_grooveshark
		@init_date = DateTime.now
		@grooveshark_client = Grooveshark::Client.new
		@grooveshark_session = @grooveshark_client.session
	end

	def play_song_for_query(query)
		
		if !@child.nil? then
			execute_tuner_command("q")
		end

		query.strip!
		songs = @grooveshark_client.search_songs(query)
		song = songs.first
		url = @grooveshark_client.get_song_url(song)

		@child = fork do
			STDIN.reopen(@read_io)
			`mplayer -really-quiet "#{url}"` 
		end
	end

	def execute_tuner_command(command)
		@write_io.write "#{command}"
	end
end
