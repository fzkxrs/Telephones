require_relative 'database'

class Auth
  attr_reader :logged_in_user
  attr_reader :role

  def initialize(db, details_fields, phone_entries, save_button, delete_button, create_button)
    @details_fields = details_fields
    @phone_entries = phone_entries
    @save_button = save_button
    @delete_button = delete_button
    @create_button = create_button
    @logged_in_user = nil # This will store the username of the logged-in user
    @role = nil # This will store the role of the logged-in user
    @db = db
  end

  def register_user(username, password)
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
        role, username = @db.authenticate_user(username, password)
        if username
          @logged_in_user = username
          @role = role
          success_dialog = Gtk::MessageDialog.new(
            parent: @window,
            flags: :destroy_with_parent,
            type: :info,
            buttons_type: :close,
            message: "Успешный вход в систему"
          )
          enable_editable_fields
          success_dialog.run
          success_dialog.destroy
          # Here, update your application's UI for logged-in users
        else
          error_dialog = Gtk::MessageDialog.new(
            parent: @window,
            flags: :destroy_with_parent,
            type: :info,
            buttons_type: :close,
            message: "Ошибка входа. Неверный логин или пароль"
          )
          error_dialog.run
          error_dialog.destroy
        end
      elsif response == Gtk::ResponseType::CANCEL
        puts "Cancelled"
      end
      dialog.destroy # Destroy the dialog after any response (OK or Cancel)
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
    dialog.add_button(Gtk::Stock::CANCEL, Gtk::ResponseType::CANCEL)
    dialog.show_all

    dialog.signal_connect('response') do |_, response|
      if response == Gtk::ResponseType::OK
        if password_entry.text != password_entry_check.text
          error_dialog = Gtk::MessageDialog.new(
            parent: @window,
            flags: :destroy_with_parent,
            type: :info,
            buttons_type: :close,
            message: "Введённные пароли не совпадают"
          )
          error_dialog.run
          error_dialog.destroy
        else
          username = username_entry.text
          password = password_entry.text
          condition = @db.create_user(username, password)
          if !condition
            success_dialog = Gtk::MessageDialog.new(
              parent: @window,
              flags: :destroy_with_parent,
              type: :info,
              buttons_type: :close,
              message: "Регистрация прошла успешно"
            )
            success_dialog.run
            success_dialog.destroy
          else
            error_dialog = Gtk::MessageDialog.new(
              parent: @window,
              flags: :destroy_with_parent,
              type: :info,
              buttons_type: :close,
              message: "Пользователь уже существует"
            )
            error_dialog.run
            error_dialog.destroy
          end
        end
      end
      dialog.destroy if response == Gtk::ResponseType::CANCEL || response == Gtk::ResponseType::OK
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

  def enable_editable_fields
    @details_fields.each_value do |field|
      field.editable = true
      field.can_focus = true
    end
    @phone_entries.each do |field|
      field.each do |element| element.editable = true end
      field.each do |element| element.can_focus = true end
    end
    @save_button.sensitive = true
    @create_button.sensitive = true
    if @role == 'admin'
      @delete_button.sensitive = true
    end
  end
end
