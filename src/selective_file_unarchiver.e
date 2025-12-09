note
	description: "Unarchiver that extracts only a specific file"
	author: "Larry Rix"

class
	SELECTIVE_FILE_UNARCHIVER

inherit
	UNARCHIVER
		redefine
			default_create
		end

create
	make,
	default_create

feature {NONE} -- Initialization

	default_create
		do
			name := "selective file unarchiver"
			target_filename := ""
			destination_path := ""
			file_extracted := False
			Precursor
		end

	make (a_filename: STRING; a_destination: STRING)
		require
			filename_not_empty: not a_filename.is_empty
			destination_not_empty: not a_destination.is_empty
		do
			default_create
			target_filename := a_filename
			destination_path := a_destination
		end

feature -- Access

	target_filename: STRING

	destination_path: STRING

	file_extracted: BOOLEAN

feature -- Status

	unarchivable (a_header: TAR_HEADER): BOOLEAN
		do
			Result := (a_header.typeflag = {TAR_CONST}.tar_typeflag_regular_file or
					   a_header.typeflag = {TAR_CONST}.tar_typeflag_regular_file_old) and then
					  a_header.filename.name.out.same_string (target_filename)
		end

	required_blocks: INTEGER
		do
			if attached active_header as l_header then
				Result := needed_blocks (l_header.size).as_integer_32
			end
		end

feature -- Output

	unarchive_block (p: MANAGED_POINTER; a_pos: INTEGER)
		local
			remaining_bytes: NATURAL_64
		do
			if attached active_file as l_file and attached active_header as l_header then
				remaining_bytes := l_header.size - (unarchived_blocks * {TAR_CONST}.tar_block_size).as_natural_64
				if remaining_bytes <= {TAR_CONST}.tar_block_size.as_natural_64 then
					l_file.put_managed_pointer (p, a_pos, remaining_bytes.as_integer_32)
					l_file.flush
					l_file.close
					file_extracted := True
				else
					l_file.put_managed_pointer (p, a_pos, {TAR_CONST}.tar_block_size)
				end
			end
			unarchived_blocks := unarchived_blocks + 1
		end

feature {NONE} -- Implementation

	do_internal_initialization
		local
			l_file: RAW_FILE
			l_dest: STRING
		do
			if attached active_header as l_header then
				l_dest := destination_path.twin
				if not l_dest.ends_with ("/") and not l_dest.ends_with ("\") then
					l_dest.append_character ('/')
				end
				l_dest.append (l_header.filename.name.out)
				create l_file.make_create_read_write (l_dest)
				active_file := l_file
			end
		end

	active_file: detachable RAW_FILE

end
