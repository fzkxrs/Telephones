class AuthUtil

  def initialize(db)
    @logged_in_user = nil # This will store the username of the logged-in user
    @db = db
  end

  def authenticate_user(username, password)
    stored_password = @db.get_stored_password_for(username)

    if stored_password && BCrypt::Password.new(stored_password) == password
      @logged_in_user = username
      true
    else
      false
    end
  end

  def logged_in?
    !@logged_in_user.nil?
  end

  def logout
    @logged_in_user = nil
  end

  def show_login_dialog
    dialog = Gtk::Dialog.new(title: "Login", parent: @window, flags: :destroy_with_parent)

    username_entry = Gtk::Entry.new
    password_entry = Gtk::Entry.new
    password_entry.visibility = false  # Make the password hidden

    dialog.content_area.add(Gtk::Label.new("Username:"))
    dialog.content_area.add(username_entry)
    dialog.content_area.add(Gtk::Label.new("Password:"))
    dialog.content_area.add(password_entry)

    dialog.add_button(Gtk::Stock::OK, :ok)
    dialog.add_button(Gtk::Stock::CANCEL, :cancel)

    dialog.signal_connect('response') do |_, response|
      if response == :ok
        username = username_entry.text
        password = password_entry.text

        if @auth.authenticate_user(username, password)
          puts "Logged in successfully!"
          # Here, update your application's UI for logged-in users
        else
          puts "Invalid credentials."
        end
      end
      dialog.destroy
    end

    dialog.show_all
  end

  def on_key_press(widget, event)
    # Check if Ctrl + Alt + '=' or '+' is pressed
    if event.state.control_mask? && event.state.mod1_mask? && (event.keyval == Gdk::Keyval::KEY_equal)
      show_login_dialog
    end
  end
end