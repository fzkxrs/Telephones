module GuiUtils
  @id = 0

  def initialize(department_combo,
                 lab_combo,
                 subdivision_combo,
                 enterprise_combo,
                 search_button,
                 details_fields,
                 fio_entry,
                 work_phone_entry,
                 phone_entries,
                 photo_event_box,
                 db
  )
    department_combo.signal_connect('changed') do
      lab_combo.remove_all
      # Enable subdivision_combo when an enterprise is selected
      if department_combo.active_text && !department_combo.active_text.empty?
        labs = db.search_by_arg("lab", "department", department_combo.active_text).append("")
        labs.each { |lab| lab_combo.append_text(lab) }
        lab_combo.sensitive = true # Enable the lab combo
      else
        lab_combo.sensitive = false
      end
    end

    subdivision_combo.signal_connect('changed') do
      department_combo.remove_all
      lab_combo.remove_all
      # Enable department_combo when an enterprise is selected
      if subdivision_combo.active_text && !subdivision_combo.active_text.empty?
        departments = db.search_by_arg("department", "subdivision", subdivision_combo.active_text).append("")
        departments.each { |department| department_combo.append_text(department) }
        department_combo.sensitive = true # Enable the department combo
      else
        department_combo.sensitive = false
      end
    end

    enterprise_combo.signal_connect('changed') do
      subdivision_combo.remove_all
      department_combo.remove_all
      lab_combo.remove_all
      # Enable subdivision_combo when an enterprise is selected
      if enterprise_combo.active_text && !enterprise_combo.active_text.empty?
        subdivisions = db.search_by_arg("subdivision", "enterprise", enterprise_combo.active_text).append("")
        subdivisions.each { |subdivision| subdivision_combo.append_text(subdivision) }
        subdivision_combo.sensitive = true # Enable the subdivision combo
      else
        subdivision_combo.sensitive = false
      end
    end

    search_button.signal_connect('clicked') do
      # Gather the search input values from the ComboBoxes and Entries
      @auth.enable_editable_fields
      fio_value = fio_entry.text.empty? ? nil : fio_entry.text
      enterprise_value = enterprise_combo.active_text == "Предприятие" ? nil : enterprise_combo.active_text
      subdivision_value = subdivision_combo.active_text == "Подразделение" ? nil : subdivision_combo.active_text
      department_value = department_combo.active_text == "Отдел/Группа" ? nil : department_combo.active_text
      lab_value = lab_combo.active_text == "Лаборатория" ? nil : lab_combo.active_text
      corp_inner_tel_value = work_phone_entry.text.empty? ? nil : work_phone_entry.text.to_i

      # Call the search_employee method with the gathered values
      res = @db.search_employee(
        enterprise_value,
        subdivision_value,
        department_value,
        lab_value,
        fio_value,
        corp_inner_tel_value
      )

      # Populate the details fields with the result if available
      if res&.any?
        # Clear the contents of the phone_entries
        phone_entries.each do |entry_set|
          entry_set.each do |entry|
            entry.text = "" # Clear the text of each phone-related entry field
          end
        end

        @id = res[0]["id"]
        details_fields[:enterprise]&.text = res[0]["enterprise"] || ""
        details_fields[:subdivision]&.text = res[0]["subdivision"] || ""
        details_fields[:department]&.text = res[0]["department"] || ""
        details_fields[:lab]&.text = res[0]["lab"] || ""
        details_fields[:fio]&.text = res[0]["fio"] || ""
        details_fields[:position]&.text = res[0]["position"] || ""
        details_fields[:corp_inner_tel]&.text = res[0]["corp_inner_tel"] || ""
        details_fields[:inner_tel]&.text = res[0]["inner_tel"] || ""
        details_fields[:email]&.text = res[0]["email"] || ""
        details_fields[:address]&.text = res[0]["address"] || ""

        i = 0
        res.each do |phone_entry_data|
          phone_entry = phone_entries[i][0]
          phone_entry.text = phone_entry_data["phone"].to_s

          fax_entry = phone_entries[i][1]
          fax_entry.text = phone_entry_data["fax"].to_s

          modem_entry = phone_entries[i][2]
          modem_entry.text = phone_entry_data["modem"].to_s

          mgr_entry = phone_entries[i][3]
          mgr_entry.text = phone_entry_data["mg"].to_s
          i += 1
        end

        # Update and show everything in the grid
      else
        # Display a message dialog to inform the user
        dialog = Gtk::MessageDialog.new(
          parent: @window,
          flags: :destroy_with_parent,
          type: :info,
          buttons_type: :close,
          message: "Не найдено совпадений по номеру телефона, ФИО или подразделениям"
        )
        dialog.run
        dialog.destroy
      end
    end

    # Signal to handle the click on the EventBox (photo_box becomes clickable)
    photo_event_box.signal_connect('button_press_event') do
      # Create a FileChooserDialog to select an image
      dialog = Gtk::FileChooserDialog.new(
        title: "Select an Image",
        parent: @window,
        action: Gtk::FileChooserAction::OPEN,
        buttons: [
          [Gtk::Stock::CANCEL, Gtk::ResponseType::CANCEL],
          [Gtk::Stock::OPEN, Gtk::ResponseType::OK]
        ]
      )

      # Add a filter for image files
      filter = Gtk::FileFilter.new
      filter.name = "Image files"
      filter.add_mime_type("image/png")
      filter.add_mime_type("image/jpeg")
      filter.add_pattern("*.png")
      filter.add_pattern("*.jpg")
      filter.add_pattern("*.jpeg")
      dialog.add_filter(filter)

      response = dialog.run

      if response == Gtk::ResponseType::OK
        selected_image_path = dialog.filename
        if File.exist?(selected_image_path)
          puts "Selected image path: #{selected_image_path}"
          if !@id.nil? && @id != 0
            @selected_image_path = selected_image_path
            @db.upload_image_to_db(selected_image_path, @id)
          end
          # You can now use the selected_image_path, e.g., load it into the UI
        else
          puts "Error: Selected file does not exist."
        end
      else
        puts "File selection was canceled."
      end

      dialog.destroy
    end
  end

  # Enable editing of fields for moderators/admins
  def save_changes(details_fields, phone_entries, role)
    entry_data = details_fields.transform_values(&:text) # Collect data from fields
    phones_data = phone_entries.map do |phone_row|
      phone_row.map do |entry|
        entry.text.to_i unless entry.text.empty?
      end
    end.reject { |phone_row| phone_row.all?(&:nil?) }
    postgres_array = "{#{phones_data.map { |row| "{#{row.join(',')}}" }.join(',')}}"
    @id = @db.upsert_entry(@id, entry_data, postgres_array, role) # Update the database with the new values
    if !@selected_image_path.nil?
      @id = @db.upload_image_to_db(@selected_image_path, @id)
    end
    if @id.nil?
      failed_dialog = Gtk::MessageDialog.new(
        parent: @window,
        flags: :destroy_with_parent,
        type: :info,
        buttons_type: :close,
        message: "Ошибка при сохранении данных"
      )
      failed_dialog.run
      failed_dialog.destroy
    else
      success_dialog = Gtk::MessageDialog.new(
        parent: @window,
        flags: :destroy_with_parent,
        type: :info,
        buttons_type: :close,
        message: "Данные успешно сохранены"
      )
      success_dialog.run
      success_dialog.destroy
    end
  end

  # Delete entry (admin only)
  def delete_entry
    confirm_dialog = Gtk::MessageDialog.new(
      parent: @window,
      flags: :destroy_with_parent,
      type: :question,
      buttons_type: :yes_no,
      message: "Вы уверены, что хотите удалить запись?"
    )

    confirm_dialog.signal_connect("response") do |_, response|
      if response == Gtk::ResponseType::YES
        @db.delete_entry(@id) # Call your DB method to delete the entry
        @id = 0
        success_dialog = Gtk::MessageDialog.new(
          parent: @window,
          flags: :destroy_with_parent,
          type: :info,
          buttons_type: :close,
          message: "Запись удалена"
        )
        success_dialog.run
        success_dialog.destroy
      end
      confirm_dialog.destroy
    end

    confirm_dialog.run
  end

  # Function to create a new user entry in the database
  def create_new_user(details_fields, phone_entries, role)
    clear_fields(details_fields, phone_entries)
    details_fields[:enterprise]&.text = role
    @auth.enable_editable_fields
    if role != "admin"
      details_fields[:enterprise].editable = false
      details_fields[:enterprise].can_focus = false
    end
  end

  def clear_fields(details_fields, phone_entries)
    details_fields[:enterprise]&.text = ""
    details_fields[:subdivision]&.text = ""
    details_fields[:department]&.text = ""
    details_fields[:lab]&.text = ""
    details_fields[:fio]&.text = ""
    details_fields[:position]&.text = ""
    details_fields[:corp_inner_tel]&.text = ""
    details_fields[:inner_tel]&.text = ""
    details_fields[:email]&.text = ""
    details_fields[:address]&.text = ""
    phone_entries.each do |entry_set|
      entry_set.each do |entry|
        entry.text = ""
      end
    end
  end
end