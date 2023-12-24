require 'rubygems'
require 'gosu'


WIDTH = 1280
HEIGHT = 720
ALBUM_SECTION_WIDTH = 400
BACKGROUND_COLOR = Gosu::Color.new(0xFF191414)
PLACE_TRACK = ALBUM_SECTION_WIDTH + 30

module ZOrder
  BACKGROUND, PLAYER, UI = *0..2
end


class Artwork
	attr_accessor :art, :dimension
	def initialize(file, leftX, topY)
		@art = Gosu::Image.new(file)
		@dimension = Dimension.new(leftX, topY, leftX + @art.width(), topY + @art.height())
	end
end

class Album
	attr_accessor :title, :artist, :artwork, :tracks
	def initialize (title, artist, artwork_loc, tracks)
		@title = title
		@artist = artist
		@artwork = artwork_loc
		@tracks = tracks
	end
end

class Track
	attr_accessor :name, :location, :dimension
	def initialize(name, location, dimension)
		@name = name
		@location = location
		@dimension = dimension
	end
end


class Dimension
	attr_accessor :leftX, :topY, :rightX, :bottomY
	def initialize(leftX, topY, rightX, bottomY)
		@leftX = leftX
		@topY = topY
		@rightX = rightX
		@bottomY = bottomY
	end
end


class MusicPlayerMain < Gosu::Window

	def initialize
			super(WIDTH,HEIGHT)
	    self.caption = "Music Player"
			@ui_font = Gosu::Font.new(20)
			@albums = read_albums()

	    @album_playing = -1
	    @track_playing = -1
			@track_playing = true
			@liked_tracks = []

			@play_button = Gosu::Image.new("UI/playbutton.png")
      @forward_icon = Gosu::Image.new("UI/forward.png")
      @backward_icon = Gosu::Image.new("UI/backward.png")
			@shuffle_button = Gosu::Image.new("UI/shuffle.png")

			@loop_toggle = false
			@loop_button_image = Gosu::Image.new("UI/loop.png")
			@loop_indicator_color = Gosu::Color::GREEN

			@music_image = Gosu::Image.new("UI/music_track.png")
			@like_button = Gosu::Image.new("UI/liked_button.png")
	end


	def read_track(music_file, index)

		track_name = music_file.gets.chomp
		track_location = music_file.gets.chomp

		leftX = PLACE_TRACK
		topY = 70 * index + 180
		rightX = WIDTH
		bottomY = topY + 50
		track_dimension = Dimension.new(leftX,topY,rightX,bottomY)
		track = Track.new(track_name,track_location,track_dimension)
		return track

	end


	def read_tracks(music_file)
		count = music_file.gets.chomp.to_i
		tracks = Array.new()

		index = 0
		while index <  count
			track = read_track(music_file, index)
			tracks << track
		index += 1
		end
		return tracks
	end


	def read_album(music_file,index)
		title = music_file.gets.chomp
		artist = music_file.gets.chomp
		leftX = 20
		spacing = 20
		topY = 45 + index * + (100 + spacing)

		artwork = Artwork.new(music_file.gets.chomp, leftX, topY)
		tracks = read_tracks(music_file)
		album = Album.new(title, artist, artwork, tracks)
		return album
	end

# read albums data from text file
	def read_albums()

		music_file = File.new("data.txt", "r")
		count = music_file.gets.chomp.to_i
		albums = Array.new()
		index = 0
		while index < count
			album = read_album(music_file, index)
			albums << album
			index += 1
		end

		music_file.close()
		return albums
	end


  # Draws the artwork on the screen for all the albums
  def draw_albums (albums)
		albums.each do |album|
			album.artwork.art.draw(album.artwork.dimension.leftX, album.artwork.dimension.topY, ZOrder::PLAYER )
			@ui_font.draw_text(album.title, album.artwork.dimension.rightX + 10, album.artwork.dimension.topY + 20, ZOrder::PLAYER, 1, 1, Gosu::Color::WHITE)
			@ui_font.draw_text(album.artist, album.artwork.dimension.rightX + 10, album.artwork.dimension.topY + 50, ZOrder::PLAYER, 1, 1, Gosu::Color::GRAY)
		end
  end

# draw the track name
	def display_track(track_name, topY)
		@ui_font.draw_text(track_name, PLACE_TRACK + 40, topY, ZOrder::PLAYER, 1, 1, Gosu::Color::WHITE)
	end

# draw the track number
	def display_num(index, topY)
		@ui_font.draw_text(index, PLACE_TRACK, topY, ZOrder::PLAYER, 1, 1, Gosu::Color::GRAY)
	end

#draw the grid for track list
  def draw_track_grid(top_y, num_tracks)
    # Spacing between each track line
    spacing = 70
    # Draw horizontal lines for the track grid
    num_tracks.times do |index|
      line_y = top_y + index * spacing
      draw_line(ALBUM_SECTION_WIDTH + 5, line_y, Gosu::Color::GRAY, WIDTH, line_y, Gosu::Color::GRAY, ZOrder::UI)
    end
  end

#highlight the currently playing track
	def draw_highlighted_track(top_y, track_height, playing_track_index)
    spacing = 70
    line_y = top_y + playing_track_index * spacing
		color = Gosu::Color.rgba(128, 128, 128, 150)
    draw_rect(ALBUM_SECTION_WIDTH + 5, line_y + 70, WIDTH - ALBUM_SECTION_WIDTH, track_height, color, ZOrder::UI)
  end

#draw the UI before selecting an album
	def draw_ui
		@button_x = (WIDTH - @play_button.width) / 2
		@button_y = HEIGHT - @play_button.height - 30
		@play_button.draw(@button_x, @button_y, ZOrder::UI)

    @forward_x = (WIDTH - @play_button.width) / 2 + 70
		@forward_y = HEIGHT - @play_button.height - 23
		@forward_icon.draw(@forward_x, @forward_y, ZOrder::UI)

    @backward_x = (WIDTH - @play_button.width) / 2 - 70
		@backward_y = HEIGHT - @play_button.height - 23
		@backward_icon.draw(@backward_x, @backward_y, ZOrder::UI)

		if @loop_toggle
      @loop_indicator_color = Gosu::Color::WHITE
    else
      @loop_indicator_color = Gosu::Color::BLACK
    end

		@loop_button_x = WIDTH - 100
		@loop_button_y = HEIGHT - @loop_button_image.height - 30
		@loop_button_image.draw(@loop_button_x, @loop_button_y, ZOrder::UI)

		draw_line(@loop_button_x, @loop_button_y + @loop_button_image.height, @loop_indicator_color,
		@loop_button_x + @loop_button_image.width, @loop_button_y + @loop_button_image.height, @loop_indicator_color,
		ZOrder::UI)
	end

#draw the UI after selecting an album
	def draw_ui2
		@shuffle_x = WIDTH - @shuffle_button.width - 100
		@shuffle_y = 100
		@shuffle_button.draw(@shuffle_x, @shuffle_y, ZOrder::UI)

		@music_image_x = 25
		@music_image_y = HEIGHT - @music_image.height - 17
		@music_image.draw(@music_image_x, @music_image_y, ZOrder::UI)

		@like_button_x = 92
    @like_button_y = @music_image_y + 32
    @like_button.draw(@like_button_x, @like_button_y, ZOrder::UI)
  end

	def draw_music_image
		@music_image.draw(0, HEIGHT - @sample_image.height, ZOrder::UI)
	end


	def draw_background
    draw_quad(
			0, 0, BACKGROUND_COLOR,
      WIDTH, 0, BACKGROUND_COLOR,
      0, HEIGHT, BACKGROUND_COLOR,
      WIDTH, HEIGHT, BACKGROUND_COLOR)


      draw_quad(
			ALBUM_SECTION_WIDTH - 3, 0, Gosu::Color::BLACK,
      ALBUM_SECTION_WIDTH + 3, 0, Gosu::Color::BLACK,
      ALBUM_SECTION_WIDTH - 3, HEIGHT, Gosu::Color::BLACK,
      ALBUM_SECTION_WIDTH + 3, HEIGHT, Gosu::Color::BLACK,
      ZOrder::UI
    )

		draw_quad(
			0, HEIGHT - 80, Gosu::Color::BLACK,
			WIDTH, HEIGHT - 80, Gosu::Color::BLACK,
			0, HEIGHT, Gosu::Color::BLACK,
			WIDTH, HEIGHT, Gosu::Color::BLACK,
			ZOrder::UI
		)


		draw_quad(
			0, 0, Gosu::Color::BLACK,
			WIDTH, 0, Gosu::Color::BLACK,
			0, 30, Gosu::Color::BLACK,
			WIDTH, 30, Gosu::Color::BLACK,
			ZOrder::UI
		)
	end


	#Play the tracks of the selected album
	def update
		# If a new album has just been seleted, and no album was selected before -> start the first song of that album
		if @album_playing >= 0 && @song == nil
			@track_playing = 0
			play_track(0, @albums[@album_playing])
		end
		if @song && !@song.playing? && !@song.paused?
      play_next_track
    end
	end


	def draw
		draw_background
		draw_ui
		draw_albums(@albums)

		if !@album_playing.nil? && @album_playing >= 0
			draw_ui2

			@ui_font.draw_text(@albums[@album_playing].tracks[@track_playing].name, @music_image_x + @music_image.width + 15 , @music_image_y + 5, ZOrder::UI, 1, 1, Gosu::Color::GRAY)

			album = @albums[@album_playing]

			ui_font1 = Gosu::Font.new(25)
			ui_font1.draw_text("Album by #{album.artist}", 420, 105, ZOrder::UI, 1, 1, Gosu::Color::WHITE)


			ui_font2 = Gosu::Font.new(50)
			ui_font2.draw_text("#{album.title}", 420, 50, ZOrder::UI, 1, 1, Gosu::Color::WHITE)

			track_count = album.tracks.length

			@albums[@album_playing].tracks.each_with_index do |track, index|
				display_track(track.name, track.dimension.topY)
				display_num(index+1, track.dimension.topY)
				draw_track_grid(225, track_count)

				# Highlight the currently playing track
				if @track_playing == index && @song&.playing?
					draw_highlighted_track(85, 70, index)
				end
			end
		end
	end


	def needs_cursor?; true; end

# function to play the tracks
  def play_track(track, album)
    @song = Gosu::Song.new(album.tracks[track].location)
    @song.play(@loop_toggle)
  end

# detect mouse sensitive areas
	def area_clicked(leftX, topY, rightX, bottomY)
		if mouse_x > leftX && mouse_x < rightX && mouse_y > topY && mouse_y < bottomY
			return true
		end
		return false
	end

# handle button click functions
	def button_down(id)
		case id
		when Gosu::MsLeft
      if @album_playing >= 0
        if area_clicked(@button_x,@button_y,@button_x + @play_button.width, @button_y + @play_button.height)
          if @song && @song.playing?
              @song.pause
          elsif @song && @song.paused?
              @song.play
          end
        end

				if area_clicked(@like_button_x, @like_button_y, @like_button_x + @like_button.width, @like_button_y + @like_button.height)
					add_favorite
				end

				if area_clicked(@loop_button_x, @loop_button_y, @loop_button_x + @loop_button_image.width, @loop_button_y + @loop_button_image.height)
					toggle_loop
				end

				if area_clicked(@shuffle_x, @shuffle_y, @shuffle_x + @shuffle_button.width, @shuffle_y + @shuffle_button.height)
						shuffle_tracks
				end

				if area_clicked(@forward_x, @forward_y, @forward_x + @forward_icon.width, @forward_y + @forward_icon.height)
						play_next_track
				end

				if area_clicked(@backward_x, @backward_y, @backward_x + @backward_icon.width, @backward_y + @backward_icon.height)
					play_previous_track
				end

        for index in 0..@albums[@album_playing].tracks.length() - 1
					if area_clicked(@albums[@album_playing].tracks[index].dimension.leftX, @albums[@album_playing].tracks[index].dimension.topY, @albums[@album_playing].tracks[index].dimension.rightX, @albums[@album_playing].tracks[index].dimension.bottomY)
						play_track(index, @albums[@album_playing])
						@track_playing = index
						break
					end
				end
			end

				for index in 0..@albums.length() - 1
					if !@albums[index].tracks.empty? && area_clicked(@albums[index].artwork.dimension.leftX, @albums[index].artwork.dimension.topY, @albums[index].artwork.dimension.rightX, @albums[index].artwork.dimension.bottomY)
						@album_playing = index
						@song = nil
						break
					end
				end
			end
		end
	end


	def add_favorite
		if @album_playing > 0 && @track_playing >= 0
			current_album = @albums[@album_playing]
			current_track = current_album.tracks[@track_playing]

			# ensure that each track can only be liked once
			if @liked_tracks.include?([@album_playing, @track_playing])
				puts "You have already liked this track"
				return
			end

			favorite_album = @albums[0]

			# Create a new track object for the blank album with an index
			favorite_track = Track.new(current_track.name, current_track.location, nil)

			# Assign an index to the newly added track
			if favorite_album.tracks.empty?
				favorite_track.dimension = Dimension.new(PLACE_TRACK, 180, WIDTH, 230)
			else
				last_track = favorite_album.tracks.last
				new_topY = last_track.dimension.bottomY + 20
				favorite_track.dimension = Dimension.new(PLACE_TRACK, new_topY, WIDTH, new_topY + 50)
			end

			# Add the track to the blank album's tracks
			favorite_album.tracks << favorite_track
			puts "Added '#{current_track.name}' to the Favorite album!"
			@liked_tracks << [@album_playing, @track_playing]
		end
	end

# toggle loop state
	def toggle_loop
    @loop_toggle = !@loop_toggle
  end


	def shuffle_tracks
		return if @album_playing < 0 || @song.nil?
		# Store the current playing track index
		current_track_index = @track_playing

		# Shuffle the tracks
		shuffled_tracks = @albums[@album_playing].tracks.shuffle

		# Find the index of the currently playing track after shuffling
		next_track_index = shuffled_tracks.find_index { |track| track.name == @albums[@album_playing].tracks[current_track_index].name }

		# Get the next random track index different from the current one
		begin
			next_track_index = rand(shuffled_tracks.length)
		end while next_track_index == current_track_index

		# Set the next track to play
		@track_playing = next_track_index
		play_current_track
	end

# move to next track
	def play_next_track
		return if @album_playing < 0 || @song.nil?

		@track_playing += 1
		@track_playing = 0 if @track_playing >= @albums[@album_playing].tracks.length

		play_current_track
	end

# move to previous track
	def play_previous_track
		return if @album_playing < 0 || @song.nil?

		@track_playing -= 1
		@track_playing = @albums[@album_playing].tracks.length - 1 if @track_playing.negative?

		play_current_track
	end

# play the track after moving
	def play_current_track
		track = @albums[@album_playing].tracks[@track_playing]
		play_track(@track_playing, @albums[@album_playing])
	end


# Show is a method that loops through update and draw

MusicPlayerMain.new.show if __FILE__ == $0
