note
	description: "Represents an entry in a tar archive"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SIMPLE_ARCHIVE_ENTRY

inherit
	ANY
		redefine
			out
		end

create
	make

feature {NONE} -- Initialization

	make (a_name: STRING)
			-- Create entry with `a_name'.
		require
			name_not_empty: not a_name.is_empty
		do
			name := a_name
			size := 0
			is_directory := False
			modification_time := 0
		ensure
			name_set: name.same_string (a_name)
		end

feature -- Access

	name: STRING
			-- Entry name (file path within archive).

	size: NATURAL_64
			-- Size in bytes (0 for directories).

	is_directory: BOOLEAN
			-- Is this a directory entry?

	modification_time: INTEGER
			-- Last modification time (Unix timestamp).

feature -- Element Change

	set_size (a_size: NATURAL_64)
			-- Set entry size.
		do
			size := a_size
		ensure
			size_set: size = a_size
		end

	set_is_directory (a_value: BOOLEAN)
			-- Set directory flag.
		do
			is_directory := a_value
		ensure
			is_directory_set: is_directory = a_value
		end

	set_modification_time (a_time: INTEGER)
			-- Set modification time.
		do
			modification_time := a_time
		ensure
			modification_time_set: modification_time = a_time
		end

feature -- Output

	out: STRING
			-- String representation.
		do
			if is_directory then
				Result := "[DIR]  " + name
			else
				Result := "[FILE] " + name + " (" + size.out + " bytes)"
			end
		end

note
	copyright: "Copyright (c) 2024-2025, Larry Rix"
	license: "MIT License"

end
