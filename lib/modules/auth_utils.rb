require_relative '../database'

class AuthUtils

  def initialize(db)
    @logged_in_user = nil # This will store the username of the logged-in user
    @db = db
  end

  def register_user(username, password)
    password_hash = BCrypt::Password.new(password)
    @db.get_stored_password_for(username)
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
    password_entry.visibility = false # Make the password hidden

    dialog.content_area.add(Gtk::Label.new("Имя пользователя:"))
    dialog.content_area.add(username_entry)
    dialog.content_area.add(Gtk::Label.new("Пароль:"))
    dialog.content_area.add(password_entry)

    dialog.add_button(Gtk::Stock::OK, Gtk::ResponseType::OK)
    dialog.add_button(Gtk::Stock::CANCEL, Gtk::ResponseType::CANCEL)

    dialog.signal_connect('response') do |_, response|
      if response == Gtk::ResponseType::OK
        username = username_entry.text
        password = password_entry.text

        if @db.authenticate_user(username, password)
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

  def show_register_dialog
    dialog = Gtk::Dialog.new(title: "Регистрация", parent: @window, flags: :destroy_with_parent)

    username_entry = Gtk::Entry.new
    password_entry = Gtk::Entry.new
    password_entry_check = Gtk::Entry.new
    password_entry.visibility = false # Make the password hidden
    password_entry_check.visibility = false

    dialog.content_area.add(Gtk::Label.new("Имя пользователя:"))
    dialog.content_area.add(username_entry)
    dialog.content_area.add(Gtk::Label.new("Пароль:"))
    dialog.content_area.add(password_entry)
    dialog.content_area.add(Gtk::Label.new("Подтверждение пароля:"))
    dialog.content_area.add(password_entry_check)

    dialog.add_button(Gtk::Stock::OK, Gtk::ResponseType::OK)
    dialog.add_button(Gtk::Stock::CANCEL, :cancel)
    dialog.show_all

    dialog.signal_connect('response') do |_, response|
      if response == Gtk::ResponseType::OK
        if password_entry.text != password_entry_check.text
          dialog = Gtk::MessageDialog.new(
            parent: @window,
            flags: :destroy_with_parent,
            type: :info,
            buttons_type: :close_connection,
            message: "Введённные пароли не совпадают"
          )
          dialog.run
        else
          username = username_entry.text
          password = password_entry.text
          if @db.authenticate_user(username, password)
            puts "Logged in successfully!"
            # Here, update your application's UI for logged-in users
          else
            puts "Invalid credentials."
          end
        end
        dialog.destroy
      end
    end
  end

  def on_key_press(widget, event)
    # Check if Ctrl + Alt + '=' or '+/-' is pressed
    if event.state.control_mask? && event.state.mod1_mask? && (event.keyval == Gdk::Keyval::KEY_equal)
      show_login_dialog
    end
    if event.state.control_mask? && event.state.mod1_mask? && (event.keyval == Gdk::Keyval::KEY_minus)
      show_register_dialog
    end
  end
end
