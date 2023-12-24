Music Player with Gosu (Ruby)

This Ruby-based music player utilizes the Gosu library to create a simple yet functional music playback interface.

Features

    Album & Track Management: Load albums and tracks from a text file to display album art, track names, and artists.
    Playback Control: Play, pause, skip tracks forward/backward, and toggle loop/shuffle functionalities.
    UI Interaction: Clickable elements for album selection, track playing, and various control buttons.
    Favorites: Ability to add liked tracks to a favorites album.

Requirements

    Ruby
    Gosu library


Install Gosu:

    gem install gosu

Usage

    Prepare a text file (data.txt) structured with albums, tracks, and their details as outlined in the code.

    Run the application:

    ruby hd-music-player.rb

    Interact with the UI:
        Click on album art to select an album.
        Control playback using the provided buttons.
        Add liked tracks to the favorites album.

Code Structure

    music_player.rb: Main application file containing the music player implementation.

        Main Class (MusicPlayerMain):
        Serves as the core class orchestrating the application's functionalities.
        Initializes the application window and manages user interactions.
        Reads albums and tracks data from a text file and populates the UI with album artwork, titles, artists, and tracks.
        Provides methods for drawing the UI elements including albums, tracks, buttons, and background.

    Supporting Classes (Artwork, Album, Track, Dimension):
        Artwork: Represents the artwork associated with an album.
        Album: Contains information about an album, including title, artist, artwork, and tracks.
        Track: Represents a music track with its name, location, and dimensions.
        Dimension: Defines the dimensions of UI elements.

    File Reading Functions:
        read_track(music_file): Reads a track from a file.
        read_tracks(music_file): Reads multiple tracks from a file and returns an array.
        read_album(music_file): Reads album information from a file and returns an Album object.
        read_albums(music_file): Reads multiple albums from a file and returns an array of Album

    User Interaction Functions:
        area_clicked(leftX, topY, rightX, botY): Checks if a specific area on the screen has been clicked.
        button_down: handle click Functions
        add_favorite, toggle_loop, shuffle_tracks,  play_next_track, play_previous_track: click Functions

    Draw Functions
    
    draw_albums, draw_track_grid, draw_highlighted_track, draw_ui, draw_ui2, draw_music_image, draw_background: draw UI 

    Directories:
        data.txt: Text file containing album and track information in the specified format.
        /artwork, /UI, : Directories holding images used for album art and UI elements.
