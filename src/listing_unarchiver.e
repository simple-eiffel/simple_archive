note
	description: "Unarchiver that collects file names without extracting"
	author: "Larry Rix"

class
	LISTING_UNARCHIVER

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
			name := "listing unarchiver"
			create entries.make (10)
			Precursor
		end

	make (a_entries: ARRAYED_LIST [STRING])
		do
			default_create
			entries := a_entries
		end

feature -- Status

	unarchivable (a_header: TAR_HEADER): BOOLEAN
		do
			Result := True
		end

	required_blocks: INTEGER
		do
			if attached active_header as l_header then
				Result := needed_blocks (l_header.size).as_integer_32
			end
		end

feature -- Output

	unarchive_block (p: MANAGED_POINTER; a_pos: INTEGER)
		do
			unarchived_blocks := unarchived_blocks + 1
		end

feature {NONE} -- Implementation

	do_internal_initialization
		do
			if attached active_header as l_header then
				entries.extend (l_header.filename.name.out)
			end
		end

	entries: ARRAYED_LIST [STRING]

end
