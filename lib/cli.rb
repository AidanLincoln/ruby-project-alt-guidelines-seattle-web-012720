require 'pry'
class CommandLineInterface
    def greeting
    puts ""
    puts "
         ██████╗██╗  ██╗ ██████╗ ██████╗ ██████╗      ██████╗ ███████╗███╗   ██╗███████╗██████╗  █████╗ ████████╗ ██████╗ ██████╗ 
        ██╔════╝██║  ██║██╔═══██╗██╔══██╗██╔══██╗    ██╔════╝ ██╔════╝████╗  ██║██╔════╝██╔══██╗██╔══██╗╚══██╔══╝██╔═══██╗██╔══██╗
        ██║     ███████║██║   ██║██████╔╝██║  ██║    ██║  ███╗█████╗  ██╔██╗ ██║█████╗  ██████╔╝███████║   ██║   ██║   ██║██████╔╝
        ██║     ██╔══██║██║   ██║██╔══██╗██║  ██║    ██║   ██║██╔══╝  ██║╚██╗██║██╔══╝  ██╔══██╗██╔══██║   ██║   ██║   ██║██╔══██╗
        ╚██████╗██║  ██║╚██████╔╝██║  ██║██████╔╝    ╚██████╔╝███████╗██║ ╚████║███████╗██║  ██║██║  ██║   ██║   ╚██████╔╝██║  ██║
         ╚═════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝╚═════╝      ╚═════╝ ╚══════╝╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝
                                                                                                                                  
    "
    end
    def main_menu
        puts ""
        puts " _________________________________________"
        puts " |                 Menu                   |"
        puts " |----------------------------------------|"
        puts " | 1 - Scale list                         |"             
        puts " | 2 - Add a new scale                    |"
        puts " | 3 - Generate a chord                   |"
        puts " | 4 - List of generated chords           |"
        puts " | 5 - Replace a chord                    |"
        puts " | 6 - Delete all chords                  |"
        puts " | 7 - Delete a scale                     |"
        puts " | 8 - Update the name of a scale         |"
        puts " | 9 - Exit                               |"
        puts " |________________________________________|"
        puts ""
    end
    def input
        response = gets.chomp
        puts ""
        if response == '1'
            Collection.scales.each do |scale|
                puts scale.name
                puts "--------"          
            end
            main_menu
            input
        elsif response == '2'
            puts "What's the name of the scale you're creating?"
            scale_name = gets.chomp
            puts "What notes are in the scale?"
            puts "- Seperate notes with commas, enter 6-7 notes,"
            puts "- do not enter flat(b) notes."
            scale_notes = gets.chomp.upcase.split(",")
            scale_length = scale_notes.length 
            all_notes = Note.all.map do |note|
                note.name
            end
            valid_notes = scale_notes.select do |note|
                all_notes.include?(note)  
            end
            if valid_notes.length == scale_length
                if scale_notes.count >= 6 && scale_notes.count <= 7
                    new_collection = Collection.create(form: 'scale', name: scale_name)
                    scale_note_ids = []
                    scale_notes.map do |note|
                        scale_note_ids << Note.find_by({name: note}).id
                    end
                    scale_note_ids.each do |note_id|
                        CollectionsNote.create(note_id: note_id, collection_id: new_collection.id)
                    end
                    puts ""
                    puts "#{scale_name} was added to the scale list."
                else               
                    puts 'Oops! Your note list was invalid.'
                end
            else
                puts 'Oops! Your note list was invalid.'
            end
            main_menu    
            input

        elsif response == '3'
            puts 'Please enter a scale name:'
            scale_string = gets.chomp
            if Collection.all.find_by({name: scale_string})
                generate_chord(scale_string)
            else
                puts "Error, no scale with that name was found."
            end
            main_menu
            input

        elsif response == '4'  
            collection_chords = Collection.where({form: 'chord'})
            
            if collection_chords.length > 1
                collection_chords.each do |collection_obj|
                    chords_note_hash = {}
                    chords_note_hash[:id] = collection_obj.id
                    notes = collection_obj.notes
                    chords_note_hash[:scale] = collection_obj.name
                    chords_note_hash[:notes] = []
                    notes.map do |note|
                        chords_note_hash[:notes] << note.name
                    end
                    puts "ID: #{chords_note_hash[:id]}, Scale: #{chords_note_hash[:scale]}, Notes: #{chords_note_hash[:notes]}"
                    puts "---------------------------------------------------"
                end
            elsif collection_chords.count == 1
                collection_chord = Collection.find_by({form: 'chord'})
                chords_note_hash = {}
                chords_note_hash[:id] = collection_chord.id
                notes = collection_chord.notes
                chords_note_hash[:scale] = collection_chord.name
                chords_note_hash[:notes] = []
                notes.map do |note|
                    chords_note_hash[:notes] << note.name
                end
                puts "ID: #{chords_note_hash[:id]}, Scale: #{chords_note_hash[:scale]}, Notes: #{chords_note_hash[:notes]}"
                puts "---------------------------------------------------"
            else
                puts "No chords have been created!"
            end
            main_menu
            input
        elsif response == '5'
            puts "Enter the ID of the chord you'd like to replace."
            chosen_id = gets.chomp
            if Collection.find_by({id: chosen_id}) 
                chosen_object = Collection.find_by({id: chosen_id}) 
                if chosen_object.form == 'chord'
                    scale_of_new_chord = chosen_object.name
                
                    CollectionsNote.where({collection_id: chosen_id}).destroy_all
                    Collection.where({id: chosen_id}).destroy(chosen_id)
                    generate_chord(scale_of_new_chord)
                else
                    puts "The ID you entered is invalid. Please refer to the chord list for a valid ID."
                end 
            else
                puts "The ID you entered is invalid. Please refer to the chord list for a valid ID."              
            end
            main_menu
            input
        elsif response == '6'
            puts "Are you sure you'd like to delete all of the generated chords?"
            puts "Type yes or no:"     
            positive = gets.chomp
            if positive == 'yes'
                if Collection.find_by({form: 'chord'})
                    collection_chord_instances = Collection.where({form: 'chord'})
                    collection_chord_instances.each do |chord_obj|
                        CollectionsNote.delete(chord_obj.id)
                        Collection.delete(chord_obj.id)
                    end
                    puts "All chords have been deleted."
                else
                    puts "There was nothing to delete!"
                end
            end
            main_menu
            input
        elsif response == '8'
            puts "Enter the scale's name that you would like to change:"
            scale_name = gets.chomp
            if Collection.find_by({name: scale_name})
                collections_w_same_name = Collection.find_by({name: scale_name})
                puts "What would you like to change the name to?"
                new_scale_name = gets.chomp
                Collection.update(collections_w_same_name.id, :name => new_scale_name)
                puts "The scale name has been updated."
            else
                puts "No scale with that name was found."
            end
            main_menu
            input
        elsif response == '9'
        puts "
        ██████╗ ██╗   ██╗███████╗
        ██╔══██╗╚██╗ ██╔╝██╔════╝
        ██████╔╝ ╚████╔╝ █████╗  
        ██╔══██╗  ╚██╔╝  ██╔══╝  
        ██████╔╝   ██║   ███████╗
        ╚═════╝    ╚═╝   ╚══════╝
                                    
        "
        
        elsif response == '7'
            puts "What's the name of the scale you'd like to delete?"
            bad_scale = gets.chomp
            puts "Are you sure you'd like to delete #{bad_scale}?"
            puts "Enter yes or no:"
            sure = gets.chomp
            if sure == "yes"
                if Collection.find_by({name: bad_scale})
                    col_id_bad_scale = Collection.find_by({name: bad_scale}).id
                    CollectionsNote.delete(col_id_bad_scale)
                    Collection.delete(col_id_bad_scale)
                    puts "#{bad_scale} has been deleted."
                else
                    puts "No scale with that name was found."
                end
            else
                puts "Deletion canceled"
            end
            main_menu
            input
        else
            puts "Sorry, I didn't get that."  
            main_menu
            input 
        end
        
    end
    def generate_chord(scale_string)
        
        scale_instance = Collection.all.find_by({name: scale_string})
        scales_collections_note = CollectionsNote.where("collection_id = #{scale_instance.id}")
        note_id_array = scales_collections_note.map do |row|
            row.note_id
        end
        #new collection(chord)
        new_chord_collection = Collection.create(form: 'chord', name: scale_string)
        #UGLY but ok, this generates an array of 3 note id's (a chord)
        chord_note_ids = []
        random_note_index = rand(note_id_array.count)
        index_below = random_note_index - 1
        index_above = random_note_index + 1
        chord_note_ids << note_id_array[random_note_index]
        note_id_array.delete_at(random_note_index)
        note_id_array.delete_at(index_below)
        note_id_array.delete_at(index_above)
        random_note_index = rand(note_id_array.count)
        chord_note_ids << note_id_array[random_note_index]
        note_id_array.delete_at(random_note_index)
        note_id_array.delete_at(index_below)
        note_id_array.delete_at(index_above)
        random_note_index = rand(note_id_array.count)
        chord_note_ids << note_id_array[random_note_index]
        #new Collections_note rows
        chord_note_ids.each do |noteid|
            CollectionsNote.create(note_id: noteid, collection_id: new_chord_collection.id)
        end
        #return an array of notes in the chord, and what scale its in
        created_chord_hash = {}
        created_chord_hash[:scale] = scale_string
        chord_note_string_array = []
        chord_note_ids.each do |note_id|
            chord_note_string_array << Note.all.find_by({id: note_id}).name
        end
        created_chord_hash[:notes] = chord_note_string_array
        puts "                  
      ;              ;              ;         
      ;;             ;;             ;;
      ;';.           ;';.           ;';.
      ;  ;;          ;  ;;          ;  ;;
      ;   ;;         ;   ;;         ;   ;;
      ;    ;;        ;    ;;        ;    ;;
      ;    ;;        ;    ;;        ;    ;;
      ;   ;'         ;   ;'         ;   ;'
      ;  '           ;  '           ;  '
 ,;;;,;         ,;;;,;         ,;;;,;
 ;;;;;;         ;;;;;;         ;;;;;;
 `;;;;'         `;;;;'         `;;;;'
        
        "       
        puts "                #{created_chord_hash[:scale]}"
        puts "               ~~~~~~~~~~~"
        puts "                #{created_chord_hash[:notes][0]}, #{created_chord_hash[:notes][1]}, #{created_chord_hash[:notes][2]}"
    end
end